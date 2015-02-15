# -*- encoding : utf-8 -*-

require 'decko/engine'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module ActiveSupport::BufferedLogger::Severity
  WAGN = UNKNOWN + 1
  
  def wagn progname, &block
    add(WAGN, nil, progname, &block)
  end
end


module Wagn
  class Application < Rails::Application

    initializer :load_wagn_environment_config, :before => :load_environment_config, :group => :all do
      add_gem_path paths, "lib/wagn/config/environments", :glob => "#{Rails.env}.rb"
      paths["lib/wagn/config/environments"].existent.each do |environment|
        require environment
      end
    end

    initializer :load_wagn_config_initializers,  :before => :load_config_initializers do
      add_gem_path paths, 'lib/wagn/config/initializers', :glob => "**/*.rb"
      config.paths['lib/wagn/config/initializers'].existent.sort.each do |initializer|
        load(initializer)
      end
    end

    class << self
      def inherited(base)
        Rails.application = base.instance
        Rails.application.add_lib_to_load_path!
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
      end
    end

    def approot_is_gemroot?
      Wagn.gem_root.to_s == config.root.to_s
    end

    def add_gem_path paths, path, options={}
      gem_path = File.join( Wagn.gem_root, path )
      with = options.delete(:with)
      with = with ? File.join(Wagn.gem_root, with) : gem_path
      #warn "add gem path #{path}, #{with}, #{gem_path}, #{options.inspect}"
      paths[path] = Rails::Paths::Path.new(paths, gem_path, with, options)
    end

    config.i18n.enforce_available_locales = true

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

    # this needs to be on the application's paths object.
    # maybe if we finally understand how these are supposed to be connected in railties we can fix lots of stuff
    paths['db/migrate'] = Rails::Paths::Path.new(paths, 'db/migrate', "#{Cardio.gem_root}/db/migrate")
    paths = Decko::Engine.config.paths
    paths['db/migrate'] = Rails::Paths::Path.new(paths, 'db/migrate', "#{Cardio.gem_root}/db/migrate")
    # should we have add_deck_paths for these?
    paths['local-mod'] = Rails::Paths::Path.new(paths, 'local-mod', "#{Rails.root}/mod") unless approot_is_gemroot?
    add_gem_path paths, "lib/tasks",           :with => "lib/wagn/tasks", :glob => "**/*.rake"
    add_gem_path paths, 'gem-assets',          :with => 'public/assets'

    paths['app/models'] = []
    paths['app/mailers'] = []

    paths['files'] = "#{Rails.root}/files"
    paths['tmp/lib'] = "#{Rails.root}/tmp/lib"
    paths['tmp/set'] = "#{Rails.root}/tmp/set"
    paths['tmp/set_pattern'] = "#{Rails.root}/tmp/set_pattern"

    # Is this needed?
    def load_tasks(app=self)
      super
#      unless approot_is_gemroot?
#        Rake::Task["db:schema:dump"].clear
#      end
      self
    end
  end
end

