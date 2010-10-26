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
    def ydhpt
      "#{User.current_user.login}, You don't have permission to"
    end

    
    module ClassMethods 
      def create_ok?()   
        ::Cardtype.create_ok?(  self.name.gsub(/.*::/,'') )
      end
      def create_ok!()   
        user, type = ::User.current_user.cardname, self.name.gsub(/.*::/,'')

        unless self.create_ok?        
          msg = "You don't have permission to create #{type} cards" 
          raise Wagn::PermissionDenied.new(msg) 
        end
      end
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

    def save_with_permissions(perform_checking=true)
      Rails.logger.debug "Card#save_with_permissions"
      if perform_checking && approved? || !perform_checking
        save_without_permissions(perform_checking)
      else
        raise ::Card::PermissionDenied.new(self)
      end
    end 
    
    def save_with_permissions!
      Rails.logger.debug "Card#save_with_permissions!"
      if approved?
        save_without_permissions!
      else
        raise ::Card::PermissionDenied.new(self)
      end
    end
 
    def approved?  
      self.operation_approved = true    
      self.permission_errors = []
      if new_record?
        approve_create_me
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


    def permit(task, party) #assign permissions
      ok! :permissions unless new_record?# might need stronger checks on new records 
      perms = self.permissions.reject { |p| p.task == task.to_s }
      perms << Permission.new(:task=>task.to_s, :party=>party)
      self.permissions= perms
    end
    
    def who_can(operation)
      perm = permissions.reject { |perm| perm.task != operation.to_s }.first   
      perm && Role[perm.party_id.to_i] 
    end 
    
    def personal_user
      return nil if simple?
      #warn "personal user tag: #{tag.extension}  #{tag.extension.class == ::User}"
      return tag.extension if tag.extension.class == ::User 
      return trunk.personal_user 
    end
    
    protected
    def you_cant(what)
      "#{ydhpt} #{what}"
      # => you_cant " #{what}"
    end
    
    def deny_because(why)    
      [why].flatten.each {|err| permission_errors << err }
      self.operation_approved = false
    end

    def lets_user(operation)
      party =  who_can(operation)
      return true if (System.always_ok? and operation != :comment)
      System.party_ok? party
    end  
    
    def approve_read
      if reader_type=='Role'
        (self.operation_approved = false) unless System.role_ok?(reader_id)
      else
        testee = template? ? trunk : self
        (self.operation_approved = false) unless testee.lets_user( :read ) 
      end
    end
       
    def approve_create_me  
      deny_because you_cant("create #{self.type} cards") unless Cardtype.create_ok?(self.type)
    end

    def approve_edit
      approve_task(:edit)
    end
    
    def approve_delete
      approve_task(:delete)
    end
    
    def approve_name
      approve_task(:edit) unless new_record?     
    end
    
    def approve_create     
      raise "must be a cardtype card" unless self.type == 'Cardtype'
      deny_because you_cant("create #{self.name} cards") unless Cardtype.create_ok?(Cardtype.classname_for(self.name))    
    end
                                    
    def approve_comment
      approve_task(:comment, 'comment on')
      deny_because("No comments allowed on template cards")       if template?  
      deny_because("No comments allowed on hard templated cards") if hard_template
    end

    def approve_task(operation, verb=nil) #read, edit, comment, delete           
      verb ||= operation.to_s
      #testee = template.hard_template? ? trunk : self
      testee = self
      deny_because("#{ydhpt} #{verb} this card") unless testee.lets_user( operation ) 
    end

    def approve_type
      unless new_record?       
        approve_delete
#        if right_template and right_template.hard_template? and right_template.type!=type and !allow_type_change
#          deny_because you_cant( "change the type of this card -- it is hard templated by #{right_template.name}")
#        end
      end
      new_self = clone_to_type( type ) 
      unless Cardtype.create_ok?(new_self.type)
        deny_because you_cant("create #{new_self.cardtype.name} cards")
      end
    end

    def approve_content
      unless new_record?
        approve_edit
        if tmpl = hard_template 
          deny_because you_cant("change the content of this card -- it is hard templated by #{tmpl.name}")
        end
      end
    end
   
    def approve_permissions
      return if System.always_ok?
      unless System.ok?(:set_card_permissions) or new_record?
        #FIXME-perm.  on new cards we should check that permission has not been altered from default unless user can set permissions. 
        deny_because you_cant("set permissions" )
      end
    end
    
    def self.included(base)   
      super
      base.extend(ClassMethods)
      base.class_eval do           
        attr_accessor :operation_approved, :permission_errors
        alias_method_chain :destroy, :permissions  
        alias_method_chain :destroy!, :permissions  
        alias_method_chain :save, :permissions
        alias_method_chain :save!, :permissions
      end
    end
  end
end
