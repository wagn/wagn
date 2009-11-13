module Wagn    
  class Initializer
    class << self
      def set_default_rails_config config    
        config.active_record.observers = :card_observer            
        config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"
        config.frameworks -= [ :action_web_service ]

        config.gem "uuid"
        config.gem "json"

        require 'yaml'   
        require 'erb'     
        database_configuration_file = 'config/database.yml'
        db = YAML::load(ERB.new(IO.read(database_configuration_file)).result)
        config.action_controller.session = {
          :session_key => db[RAILS_ENV]['session_key'],
          :secret      => db[RAILS_ENV]['secret']
        }     

        config.load_paths << "#{RAILS_ROOT}/app/addons"
      end

      def run         
        register_dispatch_callbacks
        load
      end

      # This to (re)triggers load in the development environment without depending
      # on any particular constant being loaded.
      def register_dispatch_callbacks
        ActionController::Dispatcher.prepare_dispatch do
          Wagn::Initializer.load
        end
      end
    
      def load  
        load_config  
        trigger_autoloading
      end
      
      # Modules won't necessarily get loaded unless we explicitly call them.
      # these constant invocations call the cards in a way that preserves Rails reloading
      # in development.
      def trigger_autoloading 
        Wagn::Exceptions       
        Card
        Card::Base
        Wagn::Module 
      end

      def load_config
        System
        # load wagn configuration. 
        # FIXME: this has to be here because System is both a config store and a model-- which means
        # in development mode it gets reloaded so we lose the config settings.  The whole config situation
        # needs an overhaul 
        if File.exists? "#{RAILS_ROOT}/config/sample_wagn.rb"
          require_dependency "#{RAILS_ROOT}/config/sample_wagn.rb"
        end
        if File.exists? "#{RAILS_ROOT}/config/wagn.rb" 
          require_dependency "#{RAILS_ROOT}/config/wagn.rb"    
        end

        # Configuration cleanup: Make sure System.base_url doesn't end with a /
        System.base_url.gsub!(/\/$/,'')
      end
    end   
  end
end        


