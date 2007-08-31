module Card
  module Permissions
    # Permissions --------------------------------------------------------------
    
    module ClassMethods 
      def ok?(operation)
        new.ok? operation
      end
      def ok!(operation)
        new.ok! operation
      end
    end

    # ok? and ok! are public facing methods to approve one operation at a time
    def ok?(operation) 
      self.operation_approved = true
      send("approve_#{operation}")     
      operation_approved
    end
    def ok!(operation)
      if !ok?(operation)
        raise Wagn::PermissionDenied.new(self)
      end
    end
    
    def permit(operation, party) #HACK -- outside of normal saving -- don't use in controllers yet
      if approve_permissions
        p = permissions.find_by_task(operation).party = party
        #p.party = party
        #p.save
      end
    end

    def destroy_with_permissions
      if ok? :delete
        destroy_without_permissions
      else
        false
      end
    end
    
    def destroy_with_permissions!
      if ok? :delete
        destroy_without_permissions!
      else
        raise Wagn::PermissionDenied.new(self)
      end
    end

    def save_with_permissions(perform_checking=true)
      if perform_checking && approved? || !perform_checking
        save_without_permissions(perform_checking)
      else
        false
      end
    end 
    
    def save_with_permissions!
      if approved?
        save_without_permissions!
      else
        raise Wagn::PermissionDenied.new(self)
      end
    end
    
    def permissions_with_reader=(perms)
      permissions_without_reader = perms
      reader = perms.find{|x|x.task=='reader'}
    end

    def approved?  
      self.operation_approved = true
      if new_record?
        approve_create 
      end
      updates.each_pair do |attr,value|
        send("approve_#{attr}")
      end
      operation_approved
    end
    
     
    
    protected
    def deny_because(why)    
      [why].flatten.each do |err|
        errors.add :permission_denied, err
      end
      self.operation_approved = false
    end
     
=begin  we may yet need this...
    def require_permission(operation)
      unless System.ok? operation
        deny_because "you don't have '#{operation}' permission"
      end
    end
=end

    def party_that_can(operation)
        permissions.each do |perm| 
          return perm.party if perm.task == operation.to_s
        end
        return false
      end
  
    def lets_user(operation)
      return true if System.always_ok?
      System.party_ok? party_that_can(operation)
    end

    def approve_create
      unless cardtype.lets_user :create
        deny_because "Sorry, you don't have permission to create #{cardtype.name} cards"
      end
    end
    
    def approve_read
      approve_task(:read)
    end
    def approve_edit
      approve_task(:edit)
    end
    def approve_comment
      return false unless party_that_can(:comment)
      approve_task(:comment, 'comment on')
    end
    def approve_delete
      approve_task(:delete)
    end
    
    def approve_task(operation, verb=nil) #read, edit, comment, delete
      verb ||= operation.to_s
      unless self.lets_user operation
        deny_because "Sorry, you don't have permission to #{verb} this card"
      end
    end


    def approve_name 
      approve_edit unless new_record?
    end

    def approve_type 
      approve_edit unless new_record?      
      approve_delete
      new_self = clone_to_type( type )
      new_self.send(:approve_create) 
      if err = new_self.errors.on(:permission_denied) 
        deny_because err
      end
    end

    def approve_content
      if templatee?
        deny_because "templated cards can't be edited directly"
      end
      approve_edit unless new_record?
    end
    
    def approve_personal_card
      if ::User.current_user.login == 'anon'
        deny_because("Only signed in users can have personal cards")
      end 
      if simple? or #simple cards never user cards
        !((tag.id == ::User.current_user.card.id) or
         (tag.id === 'User' and System.ok? :administrate_users) or
         (trunk.ok? :personal_card ))
        deny_because('You can only make cards plussed to your user card personal') 
      end  
    end
 
    def approve_permissions
      return if System.always_ok?
      unless System.ok? :set_card_permissions or 
          (System.ok? :set_personal_card_permissions and approve_personal_card) or 
          new_record? then #FIXME-perm.  on new cards we should check that permission has not been altered from default unless user can set permissions.
          
        deny_because "Sorry, you're not currently allowed to set permissions" 
      end
    end
    
    def self.included(base)   
      super
      base.extend(ClassMethods)
      base.class_eval do  
        attr_accessor :operation_approved 
        alias_method_chain :destroy, :permissions  
        alias_method_chain :destroy!, :permissions  
        alias_method_chain :save, :permissions
        alias_method_chain :save!, :permissions
        #alias_method_chain :permissions=, :reader
      end
      
    end
    
  end
end
