module Wagn
  class Initializer
    class << self
      def set_default_config config
        config.available_modules = Dir["#{RAILS_ROOT}/modules/*.rb"]
      end
      
      def set_default_rails_config config    
        #config.active_record.observers = :card_observer            
        config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"
        config.frameworks -= [ :action_web_service ]
        config.gem "uuid"
        config.gem "json"
        config.gem "htmlentities"
        unless ENV['RUN_CODE_RUN']
          config.gem "hoptoad_notifier"
        end
        require 'yaml'   
        require 'erb'     
        database_configuration_file = "#{RAILS_ROOT}/config/database.yml"
        db = YAML::load(ERB.new(IO.read(database_configuration_file)).result)
        config.action_controller.session = {
          :session_key => db[RAILS_ENV]['session_key'],
          :secret      => db[RAILS_ENV]['secret']
        }  
        set_default_config Wagn.config
      end

      def run
        ActionController::Dispatcher.prepare_dispatch do
          Wagn::Initializer.load
        end
      end
    
      def pre_schema?
        @@schema_initialized ||= begin
          ActiveRecord::Base.connection.select_all("select * from cards limit 3").size > 2
        rescue Exception=>e
          false
        end
        !@@schema_initialized
      end

      def load  
        load_config  
        load_cardlib                                               
        setup_multihost
        load_cardtypes
        return if pre_schema?
        load_modules
        initialize_cache
        initialize_builtin_cards
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
          CachedCard.set_cache_prefix "#{System.host}/#{RAILS_ENV}" 
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
      end

      def load_modules
        Wagn::Module.load_all
      end
          
      def initialize_builtin_cards    
        ## DEBUG
        File.open("#{RAILS_ROOT}/log/wagn.log","w") do |f|
          f.puts "Wagn::Initializer.initialize_builtin_cards"
        end
        
        %w{ *head *alert *foot *navbox *version *account_link *now }.each do |key|
          Card.add_builtin( Card.new(:name=>key, :builtin=>true))
        end
      end

      def initialize_cache
        Wagn.cache = Wagn::Cache::Main.new Rails.cache, "#{System.host}/#{RAILS_ENV}"
        Card.cache = Wagn::Cache::Base.new Wagn.cache, "card"
      end
    end
  end
  
  # oof, this is not polished
  class Config
    def initialize
      @data = {}
    end
    
    def method_missing(meth, *args)
      if meth.to_s =~ /^(.*)\=$/
        @data[$~[1]] = args[0]
      else
        @data[meth.to_s]
      end
    end
  end

  @@config = Config.new
  
  def self.config
    @@config
  end
end        


