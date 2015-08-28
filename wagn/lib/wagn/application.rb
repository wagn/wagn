# -*- encoding : utf-8 -*-

require 'decko/engine'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end


module Wagn
  class Application < Rails::Application

    initializer :load_wagn_environment_config, :before => :load_environment_config, :group => :all do
      add_path paths, "lib/wagn/config/environments", :glob => "#{Rails.env}.rb"
      paths["lib/wagn/config/environments"].existent.each do |environment|
        require environment
      end
    end

    class << self
      def inherited(base)
        super
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
      end
    end

    def add_path paths, path, options={}
      root = options.delete(:root) || Wagn.gem_root
      #gem_path = File.join( root, path )
      options[:with] = File.join(root, (options[:with] || path) )
      paths.add path, options
    end


    def config
      @config ||= begin
        config = super

        Cardio.set_config config

        config.i18n.enforce_available_locales = true
        #config.active_record.raise_in_transactional_callbacks = true

        config.assets.enabled = false
        config.assets.version = '1.0'

        config.encoding              = "utf-8"
        config.filter_parameters    += [:password]
        config.no_authentication     = false
        config.files_web_path        = 'files'

        config.email_defaults        = nil

        config.token_expiry          = 2.days
        config.revisions_per_page    = 10
        config.request_logger        = false
        config.performance_logger    = false
        config
      end
    end

    def paths
      @paths ||= begin
        paths = super
        Cardio.set_paths paths

        paths['mod'] << 'mod'
        paths.add 'files'

        paths['app/models'] = []
        paths['app/mailers'] = []

        add_path paths, 'config/routes.rb', :with => 'rails/application-routes.rb'

        Cardio.set_mod_paths  #really this should happen later

        paths
      end
    end
  end
end

