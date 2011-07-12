require 'active_support'
require 'active_record'

module Wagn end

module Wagn::Configuration
  def wagn_load
    self.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"
    self.frameworks -= [ :action_web_service ]
    require 'yaml'
    require 'erb'
    database_configuration_file = "#{RAILS_ROOT}/config/database.yml"
    db = YAML::load(ERB.new(IO.read(database_configuration_file)).result)
    self.action_controller.session = {
      :key    => db[RAILS_ENV]['session_key'],
      :secret => db[RAILS_ENV]['secret']
    }
    STDERR << "----------- Wagn Loaded -----------\n"
  end

  class << self
    def wagn_run
      wagn_load_config
      wagn_setup_multihost
      wagn_load_modules
      Wagn::Cache.initialize_on_startup
      Rails.logger.info << "----------- Wagn Rolling -----------\n\n\n"
    end

    def wagn_load_config
      Rails.logger.debug << "Load config ...\n"
      config_dir = "#{RAILS_ROOT}/config/"
      ['sample_wagn.rb','wagn.rb'].each do |filename|
        require_dependency config_dir+filename if File.exists? config_dir+filename
      end
      System.base_url.gsub!(/\/$/,'')
    end
    
    def wagn_setup_multihost
      if System.multihost and wagn_name=ENV['WAGN']
        Rails.logger.info("------- Multihost.  Wagn Name = #{ENV['WAGN']} -------")
        MultihostMapping.map_from_name(wagn_name)
      end
    end

    def wagn_load_modules
      Card
      #STDERR << "load_modules Pack load #{Wagn.const_defined?(:Pack)}\n\n"
      require_dependency "wagn/pack.rb"
      %w{modules/*.rb packs/**/*_pack.rb}.each { |d| Wagn::Pack.dir(File.expand_path( "../../#{d}/",__FILE__)) }
      Wagn::Pack.load_all
    end
  end
end
