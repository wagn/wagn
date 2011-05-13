module Wagn
  # oof, this is not polished
  class Config
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
      def config
        @@config
      end

      def rails_config
        @@rails_config
      end
    end
  end

  class Initializer
    class << self
      def set_default_config config
        config.available_modules = Dir["#{RAILS_ROOT}/modules/*.rb"] + Dir["#{RAILS_ROOT}/packs/*/*_pack.rb"]
      end

      def set_default_rails_config rails_config
        #rails_config.active_record.observers = :card_observer
        rails_config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"
        rails_config.frameworks -= [ :action_web_service ]
        require 'yaml'
        require 'erb'
        database_configuration_file = "#{RAILS_ROOT}/config/database.yml"
        db = YAML::load(ERB.new(IO.read(database_configuration_file)).result)
        rails_config.action_controller.session = {
          :session_key => db[RAILS_ENV]['session_key'],
          :secret      => db[RAILS_ENV]['secret']
        }
        @@rails_config = rails_config
        set_default_config Config.new(rails_config)
      end

      def run
        ActionController::Dispatcher.prepare_dispatch do
          Wagn::Initializer.load
        end
      end

      def pre_schema?
        begin
          @@schema_initialized ||= ActiveRecord::Base.connection.select_value("select count(*) from cards").to_i > 2
          !@@schema_initialized
        rescue
          ActiveRecord::Base.logger.info("\n----------- Schema Not Initialized -----------\n\n")
          true
        end
      end

      def load
        load_config
        load_cardlib
        setup_multihost
        load_cardtypes
        return if pre_schema?
        load_modules
#        register_mimetypes
        Wagn::Cache.initialize_on_startup
        #create_builtins
        ActiveRecord::Base.logger.info("\n----------- Wagn Initialization Complete -----------\n\n")
      end

      def load_config
        System
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

      def load_cardlib
        Cardname

        Wagn.send :include, Wagn::Exceptions
        Card.send :include, Cardlib::Exceptions

        ActiveRecord::Base.class_eval do
          include Cardlib::ActsAsCardExtension
          include Cardlib::AttributeTracking
        end

        Cardlib::ModuleMethods #load

        Card::Base.class_eval do
          include Cardlib::TrackedAttributes
          include Cardlib::Templating
          include Cardlib::Defaults
          include Cardlib::Permissions
          include Cardlib::Search
          include Cardlib::References
          include Cardlib::Cacheable
          include Cardlib::Settings
          include Cardlib::Settings::ClassMethods
          extend Cardlib::CardAttachment::ActMethods
        end
        Cardlib::Fetch # trigger autoload
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
          #Card.cache.system_prefix = Wagn::Cache.system_prefix
        end
      end

      def load_cardtypes
        Dir["#{RAILS_ROOT}/app/models/card/*.rb"].sort.each do |cardtype|
          cardtype.gsub!(/.*\/([^\/]*)$/, '\1')
          begin
            require_dependency "card/#{cardtype}"
          rescue Exception=>e
            raise "Error loading card/#{cardtype}: #{e.message}"
          end
        end
        ::Cardtype.load_cache 
        # we have to do this for now to make sure all the cardtype classes get initialized correctly, 
        # especially those with types that share names with ruby classes used elsewhere
        # eg. Date -> Card::Date (not just "Date").
        # eg2. Task (custom cardtype), which needs to be loaded as Card::Task, not Rake::Task
      end

    

  # make sure builtin cards exist
#      def create_builtins
#        User.as :wagbot do
#          %w{ *account_link *alerts *foot *head *navbox *now *version 
#              *recent_change *search *broken_link }.map do |name|
##Rails.logger.debug "create builtin cards #{name}"
#            c = Card.fetch_or_create(name)
#          end
#        end
#      end

      def load_modules
        Wagn::Module.load_all
      end

#      def register_mimetypes
#      end
    end
  end
end