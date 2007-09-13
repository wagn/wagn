class System < ActiveRecord::Base
  
  set_table_name 'system'

  cattr_writer :current_user

  
  cattr_accessor :admin_user_defaults, :base_url, :site_name,
    :invitation_email_body,  :invitation_email_subject, :invitation_request_email,
    :forgotinvitation_email_body, :forgotinvitation_email_subject, 
    :invite_request_alert_email, 
    :role_tasks, :pagesize,                 
    :enable_ruby_cards,
    :enable_server_cards,
    :request, :debug_wql
    
  self.pagesize = 20

  class << self
    def current_user
      @@current_user ||= ::User.find_by_login('anon')
    end
    
    def base_url
      if (request and request.env['HTTP_HOST'] and !@@base_url)
        'http://' + request.env['HTTP_HOST']
      else
        @@base_url
      end
    end
   
    def host
      # FIXME: hacking this so users don't have to update config.  will want to fix later 
      System.base_url.gsub(/^http:\/\//,'').gsub(/\/$/,'')
    end
      
    
    def setting(setting_name)
      template = Card.find_by_name( 'system setting' + JOINT + setting_name )
      value = template ? template.content : System.send( setting_name.gsub(/\s/,"_") )
      value.clone.substitute!( :site_name => System.site_name )
    end
    
    def admin_user
      User.find_by_login('admin')
    end
    
    def ok?(task)
      return true if always_ok?
      ok_hash.key? task.to_s
    end
    
    def ok!(task)
      if !ok?(task)
        #FIXME -- needs better error message handling
        raise Wagn::PermissionDenied.new(self.new)
      end
    end
    
    def role_ok?(role_id)
      return true if always_ok?
      ok_hash[:role_ids].key? role_id
    end
    
    def party_ok?(party)
      return true if always_ok?
      return false if party.nil?
      #warn party.inspect
      party.class.name == 'Role' ? 
         role_ok?(party.id) :
          (party == User.current_user)      
    end
    
    
    # FIXME stick this in session? cache it somehow??
    def ok_hash
      usr = User.current_user
      ok = {}
      ok[:role_ids] = {}
      usr.all_roles.each do |role|
        ok[:role_ids][role.id] = true
        role.task_list.each { |t| ok[t] = 1 }
      end
      ok
    end
    
    def always_ok?   
      return false unless usr = current_user  
      # FIXME: I think we want this case, but this doesn't seem very secure
      return true if usr.login == 'admin'
      usr.roles.each { |r| return true if r.codename == 'admin' }
      return false      
    end
  end 
  

  @@role_tasks = %w{
    set_global_permissions
    set_card_permissions
    set_personal_card_permissions
    assign_user_roles
    administrate_users
    edit_html           
  }

=begin
  manage_permissions  
  edit_cards     
  rename_cards 
  edit_cardtypes       
  remove_cards   
  set_datatypes
  invite_users        
  edit_server_cards
  deny_invitation_requests
=end

  
end
 
# load wagn configuration. 
# FIXME: this has to be here because System is both a config store and a model-- which means
# in development mode it gets reloaded so we lose the config settings.  The whole config situation
# needs an overhaul 
require_dependency "#{RAILS_ROOT}/config/sample_wagn.rb"
require_dependency "#{RAILS_ROOT}/config/wagn.rb"    

# Configuration cleanup: Make sure System.base_url ends with a /. Breaks redirects if not.
System.base_url += '/' if System.base_url && System.base_url[-1] != '/'
