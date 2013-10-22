# -*- encoding : utf-8 -*-

Card.error_codes.merge! :permission_denied=>[:denial, 403], :captcha=>[:error,449]


# ok? and ok! are public facing methods to approve one action at a time
#
#   fetching: if the optional :trait parameter is supplied, it is passed
#      to fetch and the test is perfomed on the fetched card, therefore:
#
#      :trait=>:account         would fetch this card plus a tag codenamed :account
#      :trait=>:roles, :new=>{} would initialize a new card with default ({}) options.


def ok? action
  @action_ok = true
  send "ok_to_#{action}"
  @action_ok
end

def ok_with_fetch? action, opts={}
  card = opts[:trait].nil? ? self : fetch(opts)
  card && card.ok_without_fetch?(action)
end
alias_method_chain :ok?, :fetch # note: method is chained so that we can return the instance variable @action_ok


def ok! action, opts={}
  raise Card::PermissionDenied.new self unless ok? action, opts
end

def update_account_ok? #FIXME - temporary API, I think this is fixed, can we cache any of this for speed, this is accessed for each header
  id == Account.current_id || ok?( :update, :trait=>:account )
end

def who_can action
  #warn "who_can[#{name}] #{(prc=permission_rule_card(action)).inspect}, #{prc.first.item_cards.map(&:id)}" if action == :update
  permission_rule_card(action).first.item_cards.map &:id
end


def permission_rule_card action
  opcard = rule_card action
  
  unless opcard # RULE missing.  should not be possible.  generalize this to handling of all required rules
    errors.add :permission_denied, "No #{action} rule for #{name}"
    raise Card::PermissionDenied.new(self)
  end

  rcard = Account.as_bot do
    if opcard.content == '_left' && self.junction?  # compound cards can inherit permissions from left parent
      lcard = loaded_left || left_or_new( :skip_virtual=>true, :skip_modules=>true )
      if action==:create && lcard.real? && !lcard.action==:create
        action = :update
      end
      lcard.permission_rule_card(action).first
    else
      opcard
    end
  end
  return rcard, opcard.rule_class_name
end

def rule_class_name
  trunk.type_id == Card::SetID ? cardname.trunk_name.tag : nil
end

def you_cant what
  "You don't have permission to #{what}"
end


def deny_because why
  [why].flatten.each do |message|
    errors.add :permission_denied, message
  end
  @action_ok = false
end

def permitted? action

  if !Wagn::Conf[:read_only]
    return true if action != :comment and Account.always_ok?

    permitted_ids = who_can action

    if action == :comment && Account.always_ok?
      # admin can comment if anyone can
      !permitted_ids.empty?
    else
      Account.among? permitted_ids
    end
  end
end

def permit action, verb=nil
  if Wagn::Conf[:read_only] # not called by ok_to_read
    deny_because "Currently in read-only mode"
  end
  
  verb ||= action.to_s
  unless permitted? action
    deny_because you_cant("#{verb} this card")
  end
end

def ok_to_create
  permit :create
end

def ok_to_read
  if !Account.always_ok?
    @read_rule_id ||= permission_rule_card(:read).first.id.to_i
    if !Account.as_card.read_rules.member? @read_rule_id
      deny_because you_cant "read this card"
    end
  end
end

def ok_to_update
  permit :update
  if @action_ok and type_id_changed? and !permitted? :create
    deny_because you_cant( "change to this type (need create permission)" )
  end
  ok_to_read if @action_ok
end

def ok_to_delete
  permit :delete
end

def ok_to_comment
  permit :comment, 'comment on'
  if @action_ok
    deny_because "No comments allowed on template cards" if is_template?
    deny_because "No comments allowed on hard templated cards" if hard_template
  end
end




event :set_read_rule, :before=>:store do
  if trash == true
    self.read_rule_id = self.read_rule_class = nil
  else
    # avoid doing this on simple content saves?
    rcard, rclass = permission_rule_card(:read)
    self.read_rule_id = rcard.id
    self.read_rule_class = rclass
    #find all cards with me as trunk and update their read_rule (because of *type plus right)
    # skip if name is updated because will already be resaved

    if !new_card? && type_id_changed?
      Account.as_bot do
        Card.search(:left=>self.name).each do |plus_card|
          plus_card = plus_card.refresh.update_read_rule
        end
      end
    end
  end
end

def update_read_rule
  Card.record_timestamps = false

  reset_patterns # why is this needed?
  rcard, rclass = permission_rule_card :read
  self.read_rule_id = rcard.id #these two are just to make sure vals are correct on current object
  #warn "updating read rule for #{inspect} to #{rcard.inspect}, #{rclass}"

  self.read_rule_class = rclass
  Card.where(:id=>self.id).update_all(:read_rule_id=>rcard.id, :read_rule_class=>rclass)
  expire

  # currently doing a brute force search for every card that may be impacted.  may want to optimize(?)
  Account.as_bot do
    Card.search(:left=>self.name).each do |plus_card|
      if plus_card.rule(:read) == '_left'
        plus_card.update_read_rule
      end
    end
  end

ensure
  Card.record_timestamps = true
end

def add_to_read_rule_update_queue updates
  @read_rule_update_queue = Array.wrap(@read_rule_update_queue).concat updates
end


event :check_permissions, :after=>:approve do
  act = if @action != :delete && updates.keys == ['comment'] #will be obviated by new comment handling
    :comment
  else
    @action
  end
  ok? act
end

event :process_read_rule_update_queue do
  Array.wrap(@read_rule_update_queue).each { |card| card.update_read_rule }
  @read_rule_update_queue = []
end


event :recaptcha, :before=>:approve do
  if !@nested_edit                      and
      Wagn::Env[:recaptcha_on]          and
      Card.toggle( rule :captcha )      and
      num = Wagn::Env[:recaptcha_count] and
      num < 1
      
    Wagn::Env[:recaptcha_count] = num + 1
    Wagn::Env[:controller].verify_recaptcha :model=>self, :attribute=>:captcha
  end
end


event :update_ruled_cards do
  if is_rule?
#      warn "updating ruled cards for #{name}"
    self.class.clear_rule_cache
    left.reset_set_patterns
  
    if right_id==Card::ReadID && (@name_or_content_changed || ([:create, :delete].member? @action) )
      # These instance vars are messy.  should use tracked attributes' @changed variable
      # and get rid of @name_changed, @name_or_content_changed, and @child.
      # Above should look like [:name, :content, :trash].member?( @changed.keys ).
      # To implement that, we need to make sure @changed actually tracks trash
      # (though maybe not as a tracked_attribute for performance reasons?)
      # AND need to make sure @changed gets wiped after save (probably last in the sequence)

      self.class.clear_read_rule_cache
      
#        Account.cache.reset
      Card.cache.reset # maybe be more surgical, just Account.user related
      expire #probably shouldn't be necessary,
      # but was sometimes getting cached version when card should be in the trash.
      # could be related to other bugs?
      in_set = {}
      if !(self.trash)
        if class_id = (set=left and set_class=set.tag and set_class.id)
          rule_class_ids = set_patterns.map &:key_id
          #warn "rule_class_id #{class_id}, #{rule_class_ids.inspect}"

          #first update all cards in set that aren't governed by narrower rule
           Account.as_bot do
             cur_index = rule_class_ids.index Card[read_rule_class].id
             if rule_class_index = rule_class_ids.index( class_id )
                # Why isn't this just 'trunk', do we need the fetch?
                Card.fetch(cardname.trunk_name).item_cards(:limit=>0).each do |item_card|
                  in_set[item_card.key] = true
                  next if cur_index > rule_class_index
                  item_card.update_read_rule
                end
             elsif rule_class_index = rule_class_ids.index( 0 )
               in_set[trunk.key] = true
               #warn "self rule update: #{trunk.inspect}, #{rule_class_index}, #{cur_index}"
               trunk.update_read_rule if cur_index > rule_class_index
             else warn "No current rule index #{class_id}, #{rule_class_ids.inspect}"
             end
          end

        end
      end

      #then find all cards with me as read_rule_id that were not just updated and regenerate their read_rules
      if !new_record?
        Card.where( :read_rule_id=>self.id, :trash=>false ).reject do |w|
          in_set[ w.key ]
        end.each &:update_read_rule
      end
    end
  
  end
end
