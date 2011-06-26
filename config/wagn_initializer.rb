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
    def config
      @@config
    end

    def rails_config
      @@rails_config
    end
  end
end

class Wagn::Initializer
  cattr_accessor :mods_loaded
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
#        STDERR << "Pre schema\n"
      begin
        @@schema_initialized ||= ActiveRecord::Base.connection.select_value("select count(*) from cards").to_i > 2
        !@@schema_initialized
      rescue Exception => e
        STDERR << "\n-------- Schema not initialized--------\nError: #{e}\n\n"# Trace #{e.backtrace*"\n"}"
        #ActiveRecord::Base.logger.info("\n----------- Schema Not Initialized -----------\n\n")
        true
      end
    end

    def load
      setup_multihost

      load_modules
      STDERR << "\n----------- Wagn Load Complete -----------\n\n"
      #Rails.logger.info("\n----------- Wagn Load Complete -----------\n\n")
    end

    def run
      STDERR << "\n----------- Wagn Reload Starting -----------\n\n"
      load_modules
      STDERR << "\n----------- Wagn Run Starting ---\n#{Kernel.caller*"\n"}\n--------\n\n"
      return if pre_schema?
      #STDERR << "Post Schema\n"
      Wagn::Cache.initialize_on_startup
#        load_cardtype_cache
#        STDERR << "Loaded ct cache\n"
      check_builtins
      STDERR << "\n----------- Wagn Initialization Complete -----------\n\n"
    end

    def load_config
      #System Now wagn.rb just loads a module to be included after load
      # FIXME: this has to be here because System is both a config store and a model-- which means
      # in development mode it gets reloaded so we lose the config settings.  The whole config situation
      # needs an overhaul
      STDERR << "Load config ...\n"
      if File.exists? "#{RAILS_ROOT}/config/sample_wagn.rb"
        require_dependency "#{RAILS_ROOT}/config/sample_wagn.rb"
      end
      if File.exists? "#{RAILS_ROOT}/config/wagn.rb"
        require_dependency "#{RAILS_ROOT}/config/wagn.rb"
      end

      # Configuration cleanup: Make sure System.base_url doesn't end with a /
      # (needs to go someplace else)
      #System.base_url.gsub!(/\/$/,'')
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

=begin
    def load_cardtypes
      Dir["#{RAILS_ROOT}/app/models/card/*.rb"].sort.each do |cardtype|
        cardtype.gsub!(/.*\/([^\/]*)$/, '\1')
        begin
          require_dependency "card/#{cardtype}"
        rescue Exception=>e
          raise "Error loading card/#{cardtype}: #{e.message}\nTrace #{e.backtrace*"\n"}"
        end
      end
    end
=end

    def load_cardtype_cache
      ::Cardtype.load_cache unless ['test','cucumber'].member? ENV['RAILS_ENV']
      # we were doing this to make sure all the cardtype classes get initialized correctly, 
      # especially those with types that share names with ruby classes used elsewhere
      # eg. Date -> Card::Date (not just "Date").
      # eg2. Task (custom cardtype), which needs to be loaded as Card::Task, not Rake::Task
    end

  # make sure builtin cards exist
    def check_builtins
=begin
      User.as :wagbot do
        %w{ *account_link *alerts *foot *head *navbox *now *version 
            *recent_change *search *broken_link }.map do |name|
#Rails.logger.debug "create builtin cards #{name}"
          c = Card[name]
          Rails.logger.info "Warning missing builtin card: #{name}" if c.nil?
        end
      end
=end
    end

    def load_modules
      
      #STDERR << "load_modules(#{self}) #{[:Wagn, :Card].map {|s| "#{s}->#{self.const_defined?(s)}"}*", "}, #{Wagn.const_defined?(:Pack)}\n"
      STDERR << "load_modules #{mods_loaded}, #{Wagn.const_defined?(:Pack)}\nTrace #{Kernel.caller*"\n"}\n\n"
      unless Wagn.const_defined?(:Pack)
        #Card.send :include, Wagn::Card::Model
        STDERR << "load_modules (sent include again) #{Wagn.const_defined?(:Pack)}\n\n"
        debugger
        STDERR << "load_modules 1\n"
        require_dependency "wagn/pack.rb"
      end
      #else
      return if mods_loaded
      mods_loaded = true
        STDERR << "load_modules 2\n"
        %w{modules/*.rb packs/**/*_pack.rb}.each { |d| Wagn::Pack.dir(File.expand_path( "../../#{d}/",__FILE__)) }
        STDERR << "load_modules 3\n"
        STDERR << "load_modules #{self.inspect}, #{Wagn.const_defined?(:Pack)}, #{::Card.include?(Wagn::Card::Model)}\n"
        begin
          Wagn::Pack.load_all
        rescue Exception => e
          STDERR << "Load error #{e} #{e.backtrace[0..10]*"\n"}\n"
          #Rails.logger.info "Load error #{e}"
        end
      #end
    end

#    def register_mimetypes
#    end
  end
end
