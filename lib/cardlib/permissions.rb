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
      "#{::User.current_user.cardname}, You don't have permission to"
    end

    
    module ClassMethods 
      def create_ok?()
        self.new.ok? :create
#        ::Cardtype.create_ok?(  self.name.gsub(/.*::/,'') )
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

    def save_with_permissions(perform_checking = true)  #checking is needed for update_attribute, evidently.  not sure I like it...
      Rails.logger.debug "Card#save_with_permissions!"
      run_checked_save :save_without_permissions, perform_checking
    end
     
    def save_with_permissions!(perform_checking = true)
      Rails.logger.debug "Card#save_with_permissions!", perform_checking
      run_checked_save :save_without_permissions!
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


    def permit(task, party) #assign permissions
      ok! :permissions unless new_card?# might need stronger checks on new records 
      perms = self.permissions.reject { |p| p.task == task.to_s }
      perms << Permission.new(:task=>task.to_s, :party=>party)
      self.permissions= perms
    end
    
    def who_can(operation)
      if [:create, :update, :delete, :comment].member? operation
        User.as(:wagbot ) { setting_card(operation.to_s).item_names.map &:to_key }
      else
        perm = permissions.reject { |perm| perm.task != operation.to_s }.first   
        perm && perm.party #? perm.party : nil
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
      party =  who_can(operation)
      return true if (System.always_ok? and operation != :comment)
      
      
      if Array === party
#        warn "parties = #{party.inspect}.  User parties = #{User.current_user.parties.inspect}"
        # eventually this should be the only case.
        User.as_user.among? party
      else
        System.party_ok? party
      end
    end  


    def approve_task(operation, verb=nil)           
      verb ||= operation.to_s
      #testee = template.hard_template? ? trunk : self
      testee = self

#      warn "result from lets_user = #{testee.lets_user( operation ) }" 
      deny_because("#{ydhpt} #{verb} this card") unless testee.lets_user( operation ) 
    end

    def approve_create
      approve_task(:create)
    end

    def approve_read
      if reader_type=='Role'
        (self.operation_approved = false) unless System.role_ok?(reader_id)
      else
        testee = template? ? trunk : self
        (self.operation_approved = false) unless testee.lets_user( :read ) 
      end
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
   
    def approve_permissions
      return if System.always_ok?
      unless System.ok?(:set_card_permissions) or new_card?
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
