# -*- encoding : utf-8 -*-
require 'wagn'
require File.expand_path('../boot', __FILE__)
require 'rails/all'

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
        @config = Configuration.new Pathname.new(Wagn.gem_root).expand_path
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

    custom_paths = [      
      [ 'log',                :log_file,             "log/#{Rails.env}.log" ],
      [ 'tmp',                :tmp_dir,              'tmp'                  ],
      [ 'config/database',    :database_config_file, 'config/database.yml'  ]
    ]
    
    config.paths['config/environment'] = File.expand_path( '../environment.rb', __FILE__ )
    
    custom_paths.each do |path_key, wagn_conf_key, default_path|      
      config.paths[path_key] = if configured = Wagn::Conf[wagn_conf_key]
        File.join configured
      else
        File.expand_path default_path
      end
    end


    if Wagn::Conf[:smtp]
      config.action_mailer.smtp_settings = Wagn::Conf[:smtp].symbolize_keys
    end

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += Dir["#{config.root}/mods/standard/lib/**/"]
    
  end
end

require 'paperclip' #not the right place for this!!
