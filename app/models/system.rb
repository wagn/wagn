class System < ActiveRecord::Base
  
  set_table_name 'system'
  
  cattr_accessor :role_tasks, :request,                          
    # Configuration Options 
    :base_url, :max_render_time, :max_renders,   # Common; docs in sample_wagn.rb
    :enable_ruby_cards, :enable_server_cards,    # Uncommon; Check Security risks before enabling these cardtypes (wagn.org ref url?)
    :enable_postgres_fulltext, :postgres_src_dir, :postgres_tsearch_dir, # Optimize PostgreSQL performance
    :multihost,:multihost_name,
    # In development / nonfunctional
    :google_maps_api_key,    
    # Deprecated
    :site_name, :invitation_email_body, :invitation_email_subject, :invitation_request_email, :invite_request_alert_email 
    # Crap?  :admin_user_defaults, :debug_wql, :pagesize, :time, 
    
    
  def self.javascript_files
    no_more = %{
      Wikiwyg.js
      Wikiwyg/Toolbar.js
      Wikiwyg/Wysiwyg.js
      Wikiwyg/Wikitext.js
      Wikiwyg/Preview.js
      Wikiwyg/Util.js
      Wikiwyg/HTML.js
      Wikiwyg/Debug.js
      Wagn/Wikiwyg.js
      Wagn/Lister.js
      Wagn/LinkEditor.js      
      builder.js
      window.js   
    } 
    
    # FIXME: on_demand isn't built yet.
    #  calendar should go here.
    on_demand = %w{
      transport.js  
      calendar.js             
    }

    always = %w{
      prototype.js
      effects.js 
      controls.js
      application.js  
    }
  end
  
  def self.compressed_js
    'wagn_cmp.js' 
  end  
  
  class << self
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


    # CARD-BASED SETTINGS

    def setting(name)
      User.as :admin do
        card=CachedCard.get_real(name) and !card.content.strip.empty? and card.content
        #card=CachedCard.get_real(name)  card.content
      end
    rescue
      nil
    end

    def site_title
      setting('*title') || 'Wagn'
    end
    
    def favicon
      # bit of a kludge. 
      (card_content = setting('*favicon')) ? card_content.match(/src=\"([^\"]+)/)[1] : '/images/favicon.ico'
    end
    
    def logo
      img_name = setting('*logo') 
      img_name ? "/image/#{img_name}" : File.exists?("#{RAILS_ROOT}/public/images/logo.gif") ? "/images/logo.gif" : nil
    end

    #def admin_user
    #  User.find_by_login('admin')
    #end    
    
    # PERMISSIONS
    
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
      return false if party.nil?
      return true if always_ok?
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
      return false unless usr = User.current_user  
      # FIXME: I think we want this case, but this doesn't seem very secure
      return true if usr.login == 'admin'
      usr.roles.each { |r| return true if r.codename == 'admin' }
      return false      
    end
  end 

  @@role_tasks = %w{
    set_global_permissions
    set_card_permissions
    administrate_users
    create_accounts
    assign_user_roles
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
