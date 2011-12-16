module Wagn
 class Conf
  class << self

    @@config_hash=false

    def config_hash()  @@config_hash || wagn_load_config()      end
    def [](key)         config_hash[key&&key.to_sym||key]       end
    def []=(key, value) config_hash[key&&key.to_sym||key]=value end
      
    DEFAULT_YML= %{
      role_tasks: [administrate_users, create_accounts, assign_user_roles]
    }

    # from sample_wagn.rb
#ExceptionNotifier.exception_recipients = ['person1@website.org','person2@website.org']
#ExceptionNotifier.sender_address       = '"Wagn Error" <notifier@wagn.org>'
#ExceptionNotifier.email_prefix         = "[Wagn]"

 # from model/system
 # cattr_accessor :role_tasks, :request, :cache, :main_name,
 #   # Configuration Options     
 #   :base_url, :max_render_time, :max_renders,   # Common; docs in sample_wagn.rb
 #   :enable_ruby_cards, :enable_server_cards,    # Uncommon; Check Security risks before enabling these cardtypes (wagn.org ref url?)
 #   :enable_postgres_fulltext, :postgres_src_dir, :postgres_tsearch_dir, # Optimize PostgreSQL performance
 #   :multihost, :wagn_name, :running
    

    def wagn_load_config(hash={})
      raise "Twice configged #{@@config_hash}" if @@config_hash
      @@config_hash = hash
      Rails.logger.debug "Load config ...\n"
      hash.merge! YAML.load(DEFAULT_YML)

      config_file = ENV['WAGN_CONFIG_FILE'] || "#{Rails.root}/config/wagn.yml"
      hash.merge!( YAML.load_file config_file ) if File.exists? config_file

      hash.symbolize_keys!

      if base_u = hash[:base_url]
        hash[:base_url] = base_u.gsub!(/\/$/,'')
        hash[:host] = base_u.gsub(/^http:\/\//,'').gsub(/\/.*/,'') unless hash[:host]
      end

      hash[:site_title] = Card.setting('*title') || 'Wagn'

      hash[:root_path] = begin
        epath = ENV['RAILS_RELATIVE_URL_ROOT'] 
        epath && epath != '/' ? epath : ''
      end
      
      hash[:attachment_base_url] ||= hash[:root_path] + '/files'
      hash[:attachment_storage_dir] ||= "#{Rails.root}/public/uploads"
      # bit of a kludge. 
      Card.image_settings

      Rails.logger.debug("hash #{hash.map(&:inspect)*"\n"}")
      hash
    end

    def wagn_run
#      Rails.logger.debug "wagn_run ... #{config_hash}" # leave a ref here
      #STDERR << "----------- Wagn Starting 0 -----------\n"
      wagn_setup_multihost
      #STDERR << "----------- Wagn Starting 1 -----------\n"
      Wagn::Cache.initialize_on_startup      
      #STDERR << "----------- Wagn Starting 2 -----------\n"
      wagn_load_modules
      #STDERR << "----------- Wagn reloaded 3 -----------\n"
    end

    def wagn_init
      #STDERR << "----------- Wagn init 0 -----#{Wagn::Conf[:running]}-----\n"
      return if Wagn::Conf[:running]
      #STDERR << "----------- Wagn init 1 --#{wagn_database_ready?}-------\n"
      return unless wagn_database_ready?
      #STDERR << "----------- Wagn init 2 -----------\n"
      #wagn_load_modules
      #STDERR << "----------- Wagn Starting 3 -----------\n"
      Wagn::Conf[:running] = true
      Rails.logger.info "----------- Wagn Rolling -----------\n\n\n"
    end


    def wagn_database_ready?
      no_mod_msg = "----------Wagn Running without Modules----------"
      if ActiveRecord::Base.connection.table_exists?( 'cards' )    ; true
      else; Rails.logger.info no_mod_msg + '(no cards table)'      ; false
      end
    rescue
      Rails.logger.info no_mod_msg + '(not connected to database)' ; false
    end
  
    def wagn_setup_multihost
      return unless Wagn::Conf[:multihost] and wagn_name=ENV['WAGN']
      Rails.logger.info("------- Multihost.  Wagn Name = #{wagn_name} -------")
      MultihostMapping.map_from_name(wagn_name)
    end

    def wagn_load_modules
      Card
      Cardtype
      #STDERR << "load_modules Pack load #{Wagn.const_defined?(:Pack)}\n\n"
      require_dependency "wagn/pack.rb"
      #had to start requiring renderers once they moved into their own files.  would like to go the other direction...
      %w{lib/wagn/renderer.rb lib/wagn/renderer/*.rb modules/*.rb packs/*/*_pack.rb lib/wagn/set/*/*.rb}.each { |d| Wagn::Pack.dir(File.expand_path( "../../#{d}/",__FILE__)) }
      #%w{modules/*.rb packs/*/*_pack.rb}.each { |d| Wagn::Pack.dir(File.expand_path( "../../#{d}/",__FILE__)) }
      Wagn::Pack.load_all
  
      STDERR << "----------- Wagn MODULES Loaded -----------\n"
    end

  end

 end
end
