module Cardlib                        
  class ::Card::PermissionDenied < Wagn::PermissionDenied
    attr_reader :card
    def initialize(card)
      @card = card
      super build_message 
    end    
    
    def build_message
      "for card #{@card.name}: #{@card.errors.on(:permission_denied)}"
    end
  end
       
  
  module Permissions
    # Permissions --------------------------------------------------------------

    module ClassMethods 
      def create_ok?()
        self.new.ok? :create
      end
    end

#    def generate_reader_key
#      group, indiv = [], [] 
#      who_can(:read).each do |key|
#        c = Card.fetch(key, :skip_virtual=>true)
#        case
#        when c.type == 'Role';           group << c.id
#        when c.extension_type == 'User'; indiv << c.id
#        end 
#      end
#      rkey = ''
#      rkey += "G#{group.sort.join ','}" if !group.empty?
#      rkey += "I#{indiv.sort.join ','}" if !indiv.empty?
#      rkey
#    end

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
        raise ::Card::PermissionDenied.new(self)
      end
    end
    
    def approved?  
      self.operation_approved = true    
      self.permission_errors = []
      if new_card?
        approve_create
      end
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
      raise ::Card::PermissionDenied.new(self) unless ok?(operation);  true
    end
    
    def who_can(operation)
      User.as(:wagbot ) do
        opcard = setting_card(operation.to_s)
        ok_names = opcard ? opcard.item_names : []
        ok_names.map &:to_key
      end
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
      deny_because("#{ydhpt} #{verb} this card") unless self.lets_user( operation ) 
    end

    def approve_create
      approve_task(:create)
    end

    def approve_read
      #if name == 'Home'
      #  warn "approving read for #{name}.  as_user = #{User.as_user.login}"
      #  warn " read_rule_ids = #{User.as_user.read_rule_ids.inspect}; "
      #  warn "  reader_rule_id = #{self.reader_rule_id}}"
      #end
      return true if System.always_ok?
      ok = User.as_user.read_rule_ids.member?(self.reader_rule_id)
      deny_because("#{ydhpt} read this card") unless ok
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
    
    def approve_name
      approve_task(:update) unless new_card?     
    end
    
    def approve_type
      approve_delete if !new_card?
      approve_create
    end

    def approve_content
      unless new_card?
        approve_update
        if tmpl = hard_template 
          deny_because you_cant("change the content of this card -- it is hard templated by #{tmpl.name}")
        end
      end
    end
    
    
    public
    def set_read_rules
      return if ENV['BOOTSTRAP_LOAD'] == 'true'
      self.reader_rule_id = setting_card('read').id
      if name.junction? && name.tag_name=='*read'
        #warn "found a read setting card: #{name}"
        Card.fetch(name.trunk_name).item_names.each do |item_name|
          User.as :wagbot do
            Card.fetch(item_name).update_attributes!(:reader_rule_id => self.id)
            #warn "updating #{item_name}'s reader_rule_id to #{self.id}"
            Card.cache.delete(item_name.to_key)
          end
        end
      end
      
    end
   
    
    def self.included(base)   
      super
      base.extend(ClassMethods)
      base.after_save.unshift Proc.new{|rec| rec.set_read_rules }
      base.class_eval do           
        attr_accessor :operation_approved, :permission_errors
      end
    end
  end
end
