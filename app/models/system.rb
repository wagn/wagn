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
    
    def role_ok?(role_id)
      return true if always_ok?
      ok_hash[:role_ids].key? role_id
    end
    
    # FIXME stick this in session? cache it somehow??
    def ok_hash
      usr = User.current_user
      roles = (!usr || usr.login=='anon') ? [Role.find_by_codename('anon')] :
           usr.roles + [Role.find_by_codename('anon'), Role.find_by_codename('auth')]
        
      ok = {}
      ok[:role_ids] = {}
      roles.each do |role|
        ok[:role_ids][role.id] = true
        role.task_list.each { |t| ok[t] = 1 }
      end
      ok
    end
    
    def always_ok?   
      return false unless usr = current_user
      usr.roles.each { |r| return true if r.codename == 'admin' }
      return false      
      #lots of pseudo-code here...  may be a case for "case", but I'm not
      #sure how we're going to do the not web user thing...
=begin                                
      return session[:always_ok] if session.key?(:always_ok) 

      usr = User.current_user
      if usr == :not_web_user then true 
      elsif usr == :admin_user then true
      elsif usr.roles.member?(:administrator) then true # by codename
      else false
      end
=end      
    end
    
  end 
  
  @@role_tasks = %w{  
    manage_permissions  
    edit_cards     
    rename_cards 
    edit_cardtypes       
    edit_html           
    remove_cards   
    set_datatypes
    invite_users        
    edit_server_cards
    deny_invitation_requests
  }
  
end
 
# load wagn configuration. 
# FIXME: this has to be here because System is both a config store and a model-- which means
# in development mode it gets reloaded so we lose the config settings.  The whole config situation
# needs an overhaul 
require_dependency "#{RAILS_ROOT}/config/sample_wagn.rb"
require_dependency "#{RAILS_ROOT}/config/wagn.rb"    

# Configuration cleanup: Make sure System.base_url ends with a /. Breaks redirects if not.
System.base_url += '/' if System.base_url && System.base_url[-1] != '/'
