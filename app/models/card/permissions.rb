module Card
  module Permissions
    # Permissions --------------------------------------------------------------

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

    def edit_ok?
      ok? :edit
    end                    

    def destroy_with_permissions
      if ok? :destroy
        destroy_without_permissions
      else
        false
      end
    end
    
    def destroy_with_permissions!
      if ok? :destroy
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
     
    def require_permission(operation)
      unless System.ok? operation
        deny_because "you don't have '#{operation}' permission"
      end
    end
         
    def approve_create
      if ::User.current_user.login == 'anon'
        deny_because "only authenticated users can create cards"
      end
      #require_permission :create_cards
    end

    def approve_read              
      return if System.always_ok? # FIXME: is this right?  if not we need to fix wql as well..
      if reader_id and reader_type=='Role' and !System.role_ok?(reader_id)
        deny_because "read access restricted to group #{reader.cardname}"
      end
      
      if reader_id and reader_type=='User' and ::User.current_user.id!=reader_id
        deny_because "read access is restricted to user #{reader.cardname}"
      end
    end
    
    def approve_edit 
      return if System.always_ok?
      if writer_id and writer_type=='Role' and !System.role_ok?(writer_id)
        deny_because "editing is restricted to group #{writer.cardname}"
      end

      if writer_id and writer_type=='User' and ::User.current_user.id!=writer_id
        deny_because "editing is restricted to user #{writer.cardname}"
      end

      # FIXME - this should move to Script cardtype
      if class_name=='Server' and !System.ok?( :edit_server_cards )
        deny_because "editing requires 'edit server cards' permission"
      end

      if writer_id and writer_type=='User' and ::User.current_user.id!=writer_id
        deny_because "editing is restricted to user #{writer.cardname}"
      end
    end  

    def approve_comment 
      if !appender_id
        deny_because "noone may append to this card"
      end
      return if System.always_ok?

      if appender_id and appender_type=='Role' and !System.role_ok?(appender_id)
        deny_because "appending restricted to group #{appender.cardname}"
      end

      if appender_id and appender_type=='User' and ::User.current_user.id!=appender_id
        deny_because "appending restricted to user #{appender.cardname}"
      end
    end
     
    def approve_destroy
      #approve_edit
      #require_permission :remove_cards
    end

    def approve_name 
      approve_edit unless new_record?
    end

    def approve_type 
      approve_edit unless new_record?      
      approve_destroy
      new_self = clone_to_type( type )
      new_self.send(:approve_create) 
      if err = new_self.errors.on(:permission_denied) 
        deny_because err
      end
    end

    def approve_content
      if templatee?
        deny_because "templates can't be edited"
      end
      approve_edit unless new_record?
    end
     
    
    def approve_reader
      approve_role_change(:reader, reader)
    end
                  
    def approve_writer
      approve_role_change(:writer, writer)
    end
    
    def approve_appender
      approve_role_change(:appender, appender)
    end
 
    def approve_role_change( target, party )   
      return if System.always_ok?  
      approve_edit unless new_record?
      
      if party.class == ::User and System.current_user != party
        deny_because "can't assign #{target} to user other than yourself"
      end

      if party.class == ::Role && !System.role_ok?( party.id )
        deny_because "can't assign #{target} to a group you're not in"
      end
    end   
    
    def self.included(base)   
      super
      base.class_eval do  
        attr_accessor :operation_approved 
        alias_method_chain :destroy, :permissions  
        alias_method_chain :destroy!, :permissions  
        alias_method_chain :save, :permissions
        alias_method_chain :save!, :permissions
      end
    end
    
  end
end
