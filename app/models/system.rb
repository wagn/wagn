class System < ActiveRecord::Base
  set_table_name 'system'
  cattr_accessor :admin_user_defaults, :base_url, :site_name, :node_types, 
    :invitation_email_body,  :invitation_email_subject, :invitation_request_email,
    :forgotinvitation_email_body, :forgotinvitation_email_subject,
    :role_tasks, :pagesize,
    :enable_ruby_cards,
    :enable_server_cards,
    :request, :debug_wql
    
  self.pagesize = 20

  class << self
            
    def base_url
      if (request and request.env['HTTP_HOST'] and !@@base_url)
        'http://' + request.env['HTTP_HOST']
      else
        @@base_url
      end
    end
    
    def setting(setting_name)
      template = Card.find_by_name( 'system setting' + JOINT + setting_name )
      value = template ? template.content : System.send( setting_name.gsub(/\s/,"_") )
      value.clone.substitute!( :site_name => System.site_name )
    end
    
    def admin_user
      User.find_by_login('admin')
    end
    
    def setup( clear=false )
      self.clear! if clear
      #setup_default_web
      setup_admin_user
      setup_default_home_card
      setup_hoozebot_user
    end

    def clear!()
      %w[nodes tag_revisions revisions wiki_references cards tags users].each do |table|
        ::User.connection.delete %{ delete from "#{table}" }
      end
    end

    def default_web_exists?() Web.find(:first).is_a?(Web) end
    def admin_user_exists?() ::User.find_by_name("Admin").is_a?(User) end
    def hoozebot_user_exists?() ::User.find_by_name("Hooze Bot").is_a?(User) end
    def homecard_exists?() Card.find_by_name( System.site_name ).is_a?(Card) end
    
    def setup_admin_user
      return if admin_user_exists?
      if u = ::User.find_by_login('admin')
        ::User.current_user ||= admin
        Card::User.create(:name=>'Admin',:content=>'administrative user',:user=>u)
      else
        u = ::User.new( admin_user_defaults.merge({
          :name => 'Admin', :invited_by=>1, :activated_at=>Time.now(),
          :revised_at => Time.now()
        }))
        # building the tag & card will require a current_user
        raise "Coudn't create admin User #{u.errors.plot(:to_s)}" unless u.save
        ::User.current_user = u
        u.build_tag_with_proxy_attributes.save
      end
      raise "Failed to created admin user" unless admin_user_exists?
    end
    
    def setup_default_home_card 
      return if homecard_exists?
      
      home = Card::Basic.create(:name=> System.site_name, :content=>"Welcome to [[#{System.site_name}]]")
      if home.errors.length > 0
        raise "Couldn't create Home Card: #{u.errors.plot(:to_s)}"
      end
      raise "Failed to create home card" unless homecard_exists?
    end
    
    def setup_hoozebot_user
      return if hoozebot_user_exists?
      
      # don't worry-- even though login in and passwd are set here,
      # users can't login in as hooze-bot because the account isn't
      # activated.
      admin = ::User.find_by_name('Admin') || raise( "Couldn't get admin user")
      ::User.current_user ||= admin
      if u = ::User.find_by_login('hoozebot')
        Card::User.create(:name=>'Hooze Bot',:content=>'', :user=>u)
      else
        u = ::User.new( :name=>'Hooze Bot', 
          :invited_by=>1, 
          :activated_at=>nil,
          :revised_at => Time.now(),
          :password => 'h88ze',
          :password_confirmation => 'h88ze',
          :login => 'hoozebot',
          :email => 'hoozebot@grasscommons.org',
          :created_by=>admin
        )
        u.build_tag_with_proxy_attributes
        raise "Coudn't create hoozeBot User #{u.errors.plot(:to_s)}" unless u.save
      end
      raise "Failed to create hoozebot user" unless hoozebot_user_exists?
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
      roles = usr ? 
        usr.roles + [Role.find_by_codename('anon'), Role.find_by_codename('auth')] : 
        [Role.find_by_codename('anon')]
      ok = {}
      ok[:role_ids] = {}
      roles.each do |role|
        ok[:role_ids][role.id] = true
        role.task_list.each { |t| ok[t] = 1 }
      end
      ok
    end
    
    def always_ok?   
      return false unless usr = User.current_user
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
