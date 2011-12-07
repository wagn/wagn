class System
  
  cattr_writer :attachment_storage    # storage option passed to attachment_fu   
  cattr_accessor :role_tasks, :request, :cache, :main_name,
    # Configuration Options     
    :base_url, :max_render_time, :max_renders,   # Common; docs in sample_wagn.rb
    :enable_ruby_cards, :enable_server_cards,    # Uncommon; Check Security risks before enabling these cardtypes (wagn.org ref url?)
    :enable_postgres_fulltext, :postgres_src_dir, :postgres_tsearch_dir, # Optimize PostgreSQL performance
    :multihost, :wagn_name, :running
    
    
  @@role_tasks = %w{ administrate_users create_accounts assign_user_roles }
  
  class << self
    def base_url
      if !@@base_url and request and request.env['HTTP_HOST']
        'http://' + request.env['HTTP_HOST']
      else
        @@base_url
      end
    end
    
    def root_path
      @@root_path ||= begin
        epath = ENV['RAILS_RELATIVE_URL_ROOT'] 
        epath && epath != '/' ? epath : ''
      end
    end
   
    def host
      # FIXME: hacking this so users don't have to update config.  will want to fix later 
      System.base_url ? System.base_url.gsub(/^http:\/\//,'') : ''
    end
    
    def attachment_storage
      @@attachment_storage || :file_system
    end
    
    # CARD-BASED SETTINGS

    def setting(name)
      User.as :wagbot  do
        card=Card[name] and !card.content.strip.empty? and card.content
      end
    rescue
      nil
    end           
    
    def toggle(val)
      val == '1'
    end
    
    def path_setting(name)
      name ||= '/'
      return name if name =~ /^(http|mailto)/
      System.root_path + name      
    end
    
    def image_setting(name)
      if content = setting(name) and content.match(/src=\"([^\"]+)/)
        $~[1]
      end
    end

    def site_title
      setting('*title') || 'Wagn'
    end
    
    def favicon
      # bit of a kludge. 
      image_setting('*favicon') || image_setting('*logo') || "#{root_path}/images/favicon.ico"
    end
    
    def logo
      image_setting('*logo') || (File.exists?("#{Rails.root}/public/images/logo.gif") ? "#{root_path}/images/logo.gif" : nil)
    end

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
    
    # FIXME stick this in session? cache it somehow??
    def ok_hash
      usr = User.as_user
      ok_hash = self.cache.read('ok_hash') || {}
      if ok_hash[usr.id].nil?
        ok_hash = ok_hash.dup if ok_hash.frozen?
        ok_hash[usr.id] = begin
          ok = {}
          ok[:role_ids] = {}
          usr.all_roles.each do |role|
            ok[:role_ids][role.id] = true
            role.task_list.each { |t| ok[t] = 1 }
          end
          ok
        end || false
        self.cache.write 'ok_hash', ok_hash
      end
      ok_hash[usr.id]
    end
    
    def always_ok?
      return false unless usr = User.as_user
      return true if usr.login == 'wagbot' #cannot disable
      aok_hash = self.cache.read('always') || {}
      if aok_hash[usr.id].nil?
        aok_hash = aok_hash.dup if aok_hash.frozen?
        aok_hash[usr.id] = usr.all_roles.detect { |r| r.codename == 'admin' } || false
        self.cache.write 'always', aok_hash
      end
      aok_hash[usr.id]
    end
  end
  Wagn::Configuration.wagn_load_config  
end        

