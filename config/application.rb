require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Wagn
  class Conf
    class << self
      def [](key)         @@hash[key.to_sym]            end
      def []=(key, value) @@hash[key.to_sym]=value      end
      
      WAGN_CONFIG_DEFAULTS = { :role_tasks => %w[administrate_users create_accounts assign_user_roles] }    
      WAGN_CONFIG_FILE = ENV['WAGN_CONFIG_FILE'] || File.expand_path('../wagn.yml', __FILE__)

      def load
        @@hash = h = WAGN_CONFIG_DEFAULTS

        h.merge! YAML.load_file( WAGN_CONFIG_FILE ) if File.exists? WAGN_CONFIG_FILE
        h.symbolize_keys!
      end
      
      def load_after_app 
        #could do these at normal load time but can't use Rails.root
        h = @@hash
        if base_u = h[:base_url]
          h[:base_url] = base_u.gsub!(/\/$/,'')
          h[:host] = base_u.gsub(/^https?:\/\//,'') unless h[:host]
        end

        h[:root_path] = begin
          epath = ENV['RAILS_RELATIVE_URL_ROOT'] 
          epath && epath != '/' ? epath : ''
        end
      
        h[:upload_base_url] ||= h[:root_path] + '/files'
        h[:upload_storage_dir] ||= "#{Rails.root}/local/uploads"

        h[:pack_dirs] ||= "#{Rails.root}/lib/packs, #{Rails.root}/local/packs"
      end
    end
  end
  
  
  Wagn::Conf.load
  
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    config.cache_store = :file_store, "#{Rails.root}/tmp/cache"
    
    if log_file = Wagn::Conf[:log_file]
      config.paths['log'] = File.join( log_file )
    end
    
    if db_file = Wagn::Conf[:database_config_file]
      config.paths['config/database'] = File.join( db_file )
    end

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/app/models/"]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
  end
  
  Wagn::Conf.load_after_app

  ActionDispatch::Callbacks.to_prepare do
    Wagn::Cache.initialize_on_startup
  end
  
end
