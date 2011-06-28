class Card::PermissionDenied < Wagn::PermissionDenied
  attr_reader :card
  def initialize(card)
    @card = card
    super build_message 
  end    
  
  def build_message
    "for card #{@card.name}: #{@card.errors.on(:permission_denied)}"
  end
end
       
  
  
module Wagn::Model::Permissions

  module ClassMethods 
    def create_ok?()
      self.new.ok? :create
    end
  end

  def ydhpt
    "#{::User.current_user.cardname}, You don't have permission to"
  end
  
  def destroy_with_permissions
    ok! :delete
    # FIXME this is not tested and the error will be confusing
    dependents.each do |dep| dep.ok! :delete end
    destroy_without_permissions
  end
  
  def destroy_with_permissions!
    ok! :delete
    dependents.each do |dep| dep.ok! :delete end
    destroy_without_permissions!
  end

  def save_with_permissions(perform_checking = true)  #checking is needed for update_attribute, evidently.  not sure I like it...
    Rails.logger.debug "Card#save_with_permissions!"
    run_checked_save :save_without_permissions, perform_checking
  end
   
  def save_with_permissions!(perform_checking = true)
    Rails.logger.debug "Card#save_with_permissions!"
    run_checked_save :save_without_permissions!, perform_checking
  end 
  
  def run_checked_save(method, perform_checking = true)
    if !perform_checking || approved?
      begin
        self.send(method)
      rescue Exception => e
        name.piece_names.each{|piece| Wagn::Cache.expire_card(piece.to_key)}
        Rails.logger.info "#{method}:#{e.message} #{name} #{Kernel.caller.join("\n")}"
        raise Wagn::Oops, "error saving #{self.name}: #{e.message}, #{e.backtrace}"
      end
    else
      raise Card::PermissionDenied.new(self)
    end
  end
  
  def approved?
    self.operation_approved = true    
    self.permission_errors = []
    new_card? ? ok?(:create) : ok?(:update)
    updates.each_pair do |attr,value|
      send("approve_#{attr}")
    end         
    permission_errors.each do |err|
      errors.add :permission_denied, err
    end
    operation_approved
  end
  
  # ok? and ok! are public facing methods to approve one operation at a time
  def ok?(operation)  
    self.operation_approved = true    
    self.permission_errors = []
    
    send("approve_#{operation}")     
    # approve_* methods set errors on the card.
    # that's what we want when doing approve? on save and checking each attribute
    # but we don't want just checking ok? to set errors. 
    # so we hack around the errors added in approve_* by clearing them here.    
    # self.errors.clear 

    operation_approved
  end  
  
  def ok!(operation)
    raise Card::PermissionDenied.new(self) unless ok?(operation);  true
  end
  
  def who_can(operation)
    rule_card(operation).first.item_names.map &:to_key
  end 
  
  def rule_card(operation)
    opcard = setting_card(operation.to_s)
    
    if !opcard && (!System.always_ok? || ENV['BOOTSTRAP_LOAD'] == 'true')
      raise Card::PermissionDenied.new("No #{operation} setting card for #{name}") 
    end
    
    rcard = begin
      User.as :wagbot do
        if opcard.raw_content == '_left' && self.junction?
          Card.fetch_or_new(name.trunk_name, :skip_virtual=>true, :skip_defaults=>true).rule_card(operation).first
        else
          opcard
        end
      end
    end
    return rcard, opcard.name.trunk_name.tag_name
  end
  
  protected
  def you_cant(what)
    "#{ydhpt} #{what}"
  end
      
  def deny_because(why)    
    [why].flatten.each {|err| permission_errors << err }
    self.operation_approved = false
  end

  def lets_user(operation)
    return true if (System.always_ok? and operation != :comment)
    User.as_user.among?( who_can(operation) )
  end

  def approve_task(operation, verb=nil)           
    verb ||= operation.to_s
    deny_because(you_cant "#{verb} this card") unless self.lets_user( operation ) 
  end

  def approve_create
    approve_task(:create)
  end

  def approve_read
    return true if System.always_ok?    
    self.read_rule_id ||= rule_card(:read).first.id
    ok = User.as_user.read_rule_ids.member?(self.read_rule_id) 
    deny_because(you_cant "read this card") unless ok
  end
  
  def approve_update
    approve_task(:update)
    approve_read if operation_approved
  end
  
  def approve_delete
    approve_task(:delete)
  end

  def approve_comment
    approve_task(:comment, 'comment on')
    deny_because("No comments allowed on template cards")       if template?  
    deny_because("No comments allowed on hard templated cards") if hard_template
  end
  
  
  def approve_typecode
    case
    when !cardtype_name
      deny_because("No such type")
    when !new_card? && !lets_user(:create)
      deny_because you_cant("change to this type (need create permission)"  )
    end
    #NOTE: we used to check for delete permissions on previous type, but this would really need to happen before the name gets changes 
    #(hence before the tracked_attributes stuff is run)
  end

  def approve_name
  end

  def approve_content
    unless new_card?
      if tmpl = hard_template 
        deny_because you_cant("change the content of this card -- it is hard templated by #{tmpl.name}")
      end
    end
  end
  
  
  public

  def set_read_rule
    return if ENV['BOOTSTRAP_LOAD'] == 'true'
    # avoid doing this on simple content saves?
    rcard, rclass = rule_card(:read)
    self.read_rule_id = rcard.id
    self.read_rule_class = rclass
    
    #find all cards with me as trunk and update their read_rule (because of *type plus right)
    # skip if name is updated because will already be resaved
    if !new_card? && updates.for(:typecode) #&& !updates.for(:name)
      User.as :wagbot do
        Card.search(:left=>self.name).each do |plus_card|
          plus_card.update_read_rule
        end
      end
    end
  end
  
  def update_read_rule
    rcard, rclass = rule_card(:read)
    update_attributes!(
      :read_rule_id => rcard.id,
      :read_rule_class => rclass
    )
    return if ENV['BOOTSTRAP_LOAD'] == 'true'
    # currently doing a brute force search for every card that may be impacted.  may want to optimize(?)
    User.as :wagbot do
      Card.search(:left=>self.name).each do |plus_card|
        if plus_card.setting(:read) == '_left'
          plus_card.update_read_rule
        end
      end
    end
    Card.cache.delete(self.key)
  end

  def update_ruled_cards
    return if ENV['BOOTSTRAP_LOAD'] == 'true'
    if name.junction? && name.tag_name=='*read' && @name_or_content_changed
      Wagn::Cache.expire_card self.key #probably shouldn't be necessary, 
      # but was sometimes getting cached version when card should be in the trash.
      # could be related to other bugs?
      in_set = {}
      if !(self.trash)
        rule_classes = Wagn::Pattern.subclasses.map &:key
        rule_class_index = rule_classes.index self.name.trunk_name.tag_name
        return 'not a proper rule card' unless rule_class_index

        #first update all cards in set that aren't governed by narrower rule
        User.as :wagbot do
          Card.fetch(name.trunk_name).item_cards(:limit=>0).each do |item_card|
            in_set[item_card.key] = true
            next if rule_classes.index(item_card.read_rule_class) < rule_class_index
            item_card.update_read_rule
          end
        end
      end

      #then find all cards with me as read_rule_id that were not just updated and regenerate their read_rules
      if !new_record?
        Card.find_all_by_read_rule_id_and_trash(self.id, false).each do |was_ruled|  #optimize with WQL / fetch?
          next if in_set[was_ruled.key]
          was_ruled.update_read_rule# was_ruled.rule_card(:read)
        end
      end
    end
  end
  
  def self.included(base)   
    super
    base.extend(ClassMethods)
    base.before_save.unshift Proc.new{|rec| rec.set_read_rule }
    base.after_save.unshift  Proc.new{|rec| rec.update_ruled_cards }
    base.alias_method_chain :save, :permissions
    base.alias_method_chain :save!, :permissions
    base.alias_method_chain :destroy, :permissions
    base.alias_method_chain :destroy!, :permissions
    
    base.class_eval do           
      attr_accessor :operation_approved, :permission_errors
    end
  end
end
