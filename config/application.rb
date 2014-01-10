# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)
require 'rails/all'
require 'wagn'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end


module Wagn
  class Application < Rails::Application
    

    def config
      # this is all about setting config root to gem root.
      
      if @config_reset_by_wagn #necessary because rails sets config on "def inherited" trigger
        @config
      else
        @config_reset_by_wagn = true
        gem_root = Pathname.new( File.dirname File.dirname(__FILE__) ).expand_path    
        @config = Application::Configuration.new gem_root
      end
    end
    
    
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

    cache_store = ( Wagn::Conf[:cache_store] || :file_store ).to_sym
    cache_args = case cache_store
      when :file_store
        Wagn::Conf[:file_store_dir] || "#{Rails.root}/tmp/cache"
      when :mem_cache_store, :dalli_store
        Wagn::Conf[:mem_cache_servers] || []
      end
    config.cache_store = cache_store, *cache_args

    if log_file = Wagn::Conf[:log_file]
      config.paths['log'] = File.join( log_file )
    end

    db_file = Wagn::Conf[:database_config_file] || File.expand_path( "config/database.yml" )
    config.paths['config/database'] = File.join( db_file )

    if Wagn::Conf[:smtp]
      config.action_mailer.smtp_settings = Wagn::Conf[:smtp].symbolize_keys
    end

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += Dir["#{config.root}/mods/standard/lib/**/"]
    
  end
end

require 'paperclip' #not the right place for this!!
