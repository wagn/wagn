class Card::PermissionDenied < Wagn::PermissionDenied
  attr_reader :card
  def initialize card
    @card = card
    super build_message
  end

  def build_message
    "for card #{@card.name}: #{@card.errors[:permission_denied]}"
  end
end



module Wagn::Model::Permissions

  def ydhpt
    "#{Session.user_card.name}, You don't have permission to"
  end

  def approved?
    @operation_approved = true
    @permission_errors = []

    if trash
      ok? :delete
    else
      unless updates.keys == ['comment'] # if only updating comment, next section will handle
        new_card? ? ok?(:create) : ok?(:update)
      end
      updates.each_pair do |attr,value|
        send "approve_#{attr}"
      end
    end

    @permission_errors.each do |err|
      errors.add :permission_denied, err
    end
    @operation_approved
  end

  # ok? and ok! are public facing methods to approve one operation at a time
  def ok? operation
    #warn Rails.logger.warn("ok? #{operation}")
    @operation_approved = true
    @permission_errors = []

    send "approve_#{operation}"
    # approve_* methods set errors on the card.
    # that's what we want when doing approve? on save and checking each attribute
    # but we don't want just checking ok? to set errors.
    # so we hack around the errors added in approve_* by clearing them here.
    # self.errors.clear

    @operation_approved
  end

  def ok! operation
    if ok? operation
      true
    else
      raise Card::PermissionDenied.new self
    end
  end

  def who_can(operation)
    permission_rule_card(operation).first.item_cards.map(&:id)
  end

  def permission_rule_card(operation)
    opcard = rule_card(operation)
    #warn (Rails.logger.warn "prc[#{name}]#{operation} #{opcard.inspect}") if operation.to_sym == :read
    unless opcard
      errors.add :permission_denied, "No #{operation} setting card for #{name}"
      raise Card::PermissionDenied.new(self)
    end

    rcard = begin
      Session.as_bot do
        #warn (Rails.logger.debug "in permission_rule_card #{opcard&&opcard.name} #{operation}")
        if opcard.content == '_left' && self.junction?
          lcard = loaded_trunk || Card.fetch_or_new(cardname.trunk_name, :skip_virtual=>true, :skip_modules=>true)
          lcard.permission_rule_card(operation).first
        else
          opcard
        end
      end
    end
    #warn (Rails.logger.debug "permission_rule_card[#{name}] #{rcard&&rcard.name}, #{opcard.name.inspect}, #{opcard}, #{opcard.cardname.inspect}")
    return rcard, opcard.cardname.trunk_name.tag
  end

  protected
  def you_cant(what)
    "#{ydhpt} #{what}"
  end

  def deny_because why
    [why].flatten.each {|err| @permission_errors << err }
    @operation_approved = false
  end

  def lets_user operation
    return false if operation != :read    and Wagn::Conf[:read_only]
    return true  if operation != :comment and Session.always_ok?

    permitted_ids = who_can operation

    if operation == :comment && Session.always_ok?
      # admin can comment if anyone can
      !permitted_ids.empty?
    else
      Session.among? permitted_ids
    end
  end

  def approve_task operation, verb=nil
    deny_because "Currently in read-only mode" if operation != :read && Wagn::Conf[:read_only]
    verb ||= operation.to_s
    #warn "approve_task(#{operation}, #{verb})"
    deny_because you_cant("#{verb} this card") unless self.lets_user( operation )
  end

  def approve_create
    approve_task :create
  end

  def approve_read
    #warn "AR #{name} #{Session.always_ok?}"
    return true if Session.always_ok?
    @read_rule_id ||= permission_rule_card(:read).first.id.to_i
    #warn Rails.logger.warn("AR #{name} #{@read_rule_id}, #{Session.as_card.inspect}>")
    unless Session.as_card.read_rules.member?(@read_rule_id.to_i)
      deny_because you_cant("read this card")
    end
  end

  def approve_update
    approve_task :update
    approve_read if @operation_approved
  end

  def approve_delete
    approve_task :delete
  end

  def approve_comment
    approve_task :comment, 'comment on'
    if @operation_approved
      deny_because "No comments allowed on template cards" if template?
      deny_because "No comments allowed on hard templated cards" if hard_template
    end
  end

  def approve_type_id
    case
    when !type_name
      deny_because("No such type")
    when !new_card? && reset_patterns && !lets_user(:create)
      deny_because you_cant("change to this type (need create permission)"  )
    end
    #NOTE: we used to check for delete permissions on previous type, but this would really need to happen before the name gets changes
    #(hence before the tracked_attributes stuff is run)
  end

  def approve_name
  end

  def approve_content
    if !new_card? && hard_template
      deny_because you_cant("change the content of this card -- it is hard templated by #{template.name}")
    end
  end


  public

  def set_read_rule
    if trash == true
      self.read_rule_id = self.read_rule_class = nil
    else
      # avoid doing this on simple content saves?
      rcard, rclass = permission_rule_card(:read)
      self.read_rule_id = rcard.id
      self.read_rule_class = rclass
      #find all cards with me as trunk and update their read_rule (because of *type plus right)
      # skip if name is updated because will already be resaved

      if !new_card? && updates.for(:type_id)
        Session.as_bot do
          Card.search(:left=>self.name).each do |plus_card|
            plus_card = plus_card.refresh if plus_card.frozen?
            plus_card.update_read_rule
          end
        end
      end
    end
  end

  def update_read_rule
    #warn "uprr #{name}"
    Card.record_timestamps = false

    reset_patterns # why is this needed?
    rcard, rclass = permission_rule_card :read
    self.read_rule_id = rcard.id #these two are just to make sure vals are correct on current object
    #warn "updating read rule for #{name} to #{rcard.id}, #{rcard.name}, #{rclass}"

    self.read_rule_class = rclass
    Card.where(:id=>self.id).update_all(:read_rule_id=>rcard.id, :read_rule_class=>rclass)
    expire

    # currently doing a brute force search for every card that may be impacted.  may want to optimize(?)
    Session.as_bot do
      Card.search(:left=>self.name).each do |plus_card|
        if plus_card.rule(:read) == '_left'
          plus_card.update_read_rule
        end
      end
    end

  ensure
    Card.record_timestamps = true
  end

  # fifo of cards that need read rules updated
  def update_read_rule_list() @update_read_rule_list ||= [] end
  def read_rule_updates updates
    Rails.logger.warn "rrups #{updates.inspect}"
    #warn "rrups #{updates.inspect}"
    @update_read_rule_list = update_read_rule_list.concat updates
    # to short circuite the queue mechanism, just each the new list here and update
  end

  def update_queue
    #warn (Rails.logger.warn "update queue[#{inspect}] Q[#{self.update_read_rule_list.inspect}]")

    self.update_read_rule_list.each { |card| card.update_read_rule }
    self.update_read_rule_list = []
  end

  def update_ruled_cards
    # FIXME: codename
    if junction? && tag_id==Card::ReadID && (@name_or_content_changed || @trash_changed)
      # These instance vars are messy.  should use tracked attributes' @changed variable
      # and get rid of @name_changed, @name_or_content_changed, and @trash_changed.
      # Above should look like [:name, :content, :trash].member?( @changed.keys ).
      # To implement that, we need to make sure @changed actually tracks trash
      # (though maybe not as a tracked_attribute for performance reasons?)
      # AND need to make sure @changed gets wiped after save (probably last in the sequence)

      User.cache.reset
      Card.cache.reset # maybe be more surgical, just Session.user related
      expire #probably shouldn't be necessary,
      # but was sometimes getting cached version when card should be in the trash.
      # could be related to other bugs?
      in_set = {}
      if !(self.trash)
        if class_id = (set=left and set_class=set.tag and set_class.id)
        rule_class_ids = Wagn::Model::Pattern.subclasses.map &:key_id
        if rule_class_index = rule_class_ids.index( class_id )

            #first update all cards in set that aren't governed by narrower rule
            Session.as_bot do
              Card.fetch(cardname.trunk_name).item_cards(:limit=>0).each do |item_card|
                in_set[item_card.key] = true
                #Rails.logger.debug "rule_class_ids[#{rule_class_index}] #{rule_class_ids.inspect} This:#{item_card.read_rule_class.inspect} idx:#{rule_class_ids.index(item_card.read_rule_class)}"
                rc_index = rule_class_ids.index Card[item_card.read_rule_class].id # FIXME: migrate rr_class to rr_class_id
                next if rc_index < rule_class_index
                item_card.update_read_rule
              end
            end

          else
            Airbrake.notify 'improper rule card' if Airbrake.configuration.api_key
            warn "not a proper rule card #{name}, #{Card[class_id].name} is not in rc:#{rule_class_ids.map{|x|Card[x].name}*', '}"
            return false
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
