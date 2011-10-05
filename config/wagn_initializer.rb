#require 'active_support'
#require 'active_record'

module Wagn end

module Wagn::Configuration
  def wagn_load
    self.cache_store = :file_store, "#{Rails.root}/tmp/cache"
    
    self.after_initialize do Wagn::Configuration.wagn_run end

#    self.frameworks -= [ :action_web_service ]
    #require 'yaml'
    #require 'erb'
    #database_configuration_file = "#{Rails.root}/config/database.yml"
    #db = YAML::load(ERB.new(IO.read(database_configuration_file)).result)
    
    
#    self.action_controller.session = {
#      :key    => db[Rails.env]['session_key'],
#      :secret => db[Rails.env]['secret']
#    }
    STDERR << "----------- Wagn Loaded -----------\n"
  end

  class << self
    def wagn_load_config  #loads when System.rb loads
      Rails.logger.debug "Load config ...\n"
      config_dir = "#{Rails.root}/config/"
      ['sample_wagn.rb','wagn.rb'].each do |filename|
#        STDERR << "#{filename} exists? #{File.exists? config_dir+filename}\n"
        require_dependency config_dir+filename if File.exists? config_dir+filename
      end
      System.base_url.gsub!(/\/$/,'')
    end

    def wagn_run
      wagn_load_config
      wagn_setup_multihost
      return unless wagn_database_ready?
      wagn_load_modules
      Wagn::Cache.initialize_on_startup      
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
      return unless System.multihost and wagn_name=ENV['WAGN']
      Rails.logger.info("------- Multihost.  Wagn Name = #{wagn_name} -------")
      MultihostMapping.map_from_name(wagn_name)
    end

    def wagn_load_modules
      Card
      Cardtype
      #STDERR << "load_modules Pack load #{Wagn.const_defined?(:Pack)}\n\n"
      require_dependency "wagn/pack.rb"
      %w{modules/*.rb packs/*/*_pack.rb}.each { |d| Wagn::Pack.dir(File.expand_path( "../../#{d}/",__FILE__)) }
      Wagn::Pack.load_all
      
      STDERR << "----------- Wagn MODULES Loaded -----------\n"
    end
    
    
  end
end
