require 'active_support'
require 'active_record'

module Wagn end

# oof, this is not polished
class Wagn::Config
  def initialize(config)
    @@rails_config = config
    @@config = self
    @data = {}
  end

  def method_missing(meth, *args)
    if meth.to_s =~ /^(.*)\=$/
      @data[$~[1]] = args[0]
    else
      @data[meth.to_s]
    end
  end

  class <<self
    def config() @@config end
    def rails_config() @@rails_config end
  end
end

class Wagn::Initializer
  class << self
    def set_default_rails_config rails_config
      #rails_config.active_record.observers = :card_observer
      rails_config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"
      rails_config.frameworks -= [ :action_web_service ]
      require 'yaml'
      require 'erb'
      database_configuration_file = "#{RAILS_ROOT}/config/database.yml"
      db = YAML::load(ERB.new(IO.read(database_configuration_file)).result)
      rails_config.action_controller.session = {
        :key    => db[RAILS_ENV]['session_key'],
        :secret => db[RAILS_ENV]['secret']
      }
      Wagn::Config.new(rails_config)

      load_config
    end

    def pre_schema?
#     STDERR << "Pre schema\n"
      begin
        @@schema_initialized ||= ActiveRecord::Base.connection.select_value("select count(*) from cards").to_i > 2
        !@@schema_initialized
      rescue Exception => e
        STDERR << "\n-------- Schema not initialized--------"# Trace #{e.backtrace*"\n"}"
        #ActiveRecord::Base.logger.info("\n----------- Schema Not Initialized -----------\n\n")
        true
      end
    end

    def load
      setup_multihost

      if ENV['RAILS_ENV'] == 'cucumber'
        #ActionController::Dispatcher.to_prepare { run }
      end
      STDERR << "----------- Wagn Load Complete -----------\n"
      #Rails.logger.info("\n----------- Wagn Load Complete -----------\n\n")
    end

    def run
      STDERR << "----------- Wagn Reload Starting -----------\n"
      load_modules
      return if pre_schema?
      Wagn::Cache.initialize_on_startup
      STDERR << "----------- Wagn Initialization Complete -----------\n\n\n"
    end

    def load_config
      #System Now wagn.rb just loads a module to be included after load
      STDERR << "Load config ...\n"
      if File.exists? "#{RAILS_ROOT}/config/sample_wagn.rb"
        require_dependency "#{RAILS_ROOT}/config/sample_wagn.rb"
      end
      if File.exists? "#{RAILS_ROOT}/config/wagn.rb"
        require_dependency "#{RAILS_ROOT}/config/wagn.rb"
      end
    end

    def setup_multihost
      # set schema for multihost wagns   (make sure this is AFTER loading wagn.rb duh)
      #ActiveRecord::Base.logger.info("------- multihost = #{System.multihost} and WAGN_NAME= #{ENV['WAGN']} -------")
      if System.multihost and ENV['WAGN']
        if mapping = MultihostMapping.find_by_wagn_name(ENV['WAGN'])
          System.base_url = "http://" + mapping.canonical_host
          System.wagn_name = mapping.wagn_name
        end
        ActiveRecord::Base.connection.schema_search_path = ENV['WAGN']
        ::Card.cache.system_prefix = Wagn::Cache.system_prefix
      end
    end

    def load_modules
      Card
      #STDERR << "load_modules Pack load #{Wagn.const_defined?(:Pack)}\n\n"
      require_dependency "wagn/pack.rb"
      %w{modules/*.rb packs/**/*_pack.rb}.each { |d| Wagn::Pack.dir(File.expand_path( "../../#{d}/",__FILE__)) }
      Wagn::Pack.load_all
    end
  end
end
