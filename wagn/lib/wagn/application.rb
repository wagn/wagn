# -*- encoding : utf-8 -*-

require 'decko/engine'

require 'active_support/core_ext/numeric/time'
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

=begin needs to by copied?
    initializer :load_mod_initializers,  :after => :load_wagn_config_initializers do
      paths.add 'mod-initializers', :with=>'mod', :glob=>"**{,/*/**}/initializers/*.rb"
      config.paths['mod-initializers'].existent.sort.each do |initializer|
        load(initializer)
      end
    end
=end
    
    class << self
      def inherited(base)
        Rails.application = base.instance
        Rails.application.add_lib_to_load_path!
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
      end
    end

    def config
      @config ||= begin
        config = super

        config.autoload_paths << "#{Rails.root}/tmp/lib"

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

        config
      end
    end

    def paths
      @paths ||= begin
        Decko::Engine.paths['local-mod'] = approot_is_gemroot? ? [] : ["#{Rails.root}/mod"]
        paths = super
        #add_gem_path paths, "app",                 :card => true, :eager_load => true, :glob => "*"
        #add_gem_path paths, "app/assets",          :glob => "*"
        add_gem_path paths, "lib/tasks",           :with => "lib/wagn/tasks", :glob => "**/*.rake"
        add_gem_path paths, 'gem-assets',          :with => 'public/assets'

        paths['app/models'] = []
        paths['app/mailers'] = []

        paths.add 'files'
        paths.add 'tmp/set'
        paths.add 'tmp/set_pattern'
        paths
      end
    end

    def approot_is_gemroot?
      Wagn.gem_root.to_s == config.root.to_s
    end

    def add_gem_path paths, path, options={}
      gem_root = options.delete(:card) ? Card.gem_root : Wagn.gem_root
      gem_path = File.join( gem_root, path )
      with = options.delete(:with)
      with = with ? File.join(gem_root, with) : gem_path
      #warn "add gem path #{path}, #{with}, #{gem_path}, #{options.inspect}"
      paths[path] = Rails::Paths::Path.new(paths, gem_path, with, options)
    end

    def load_tasks(app=self)
      super
#      unless approot_is_gemroot?
#        Rake::Task["db:schema:dump"].clear
#      end
      self
    end
  end
end

