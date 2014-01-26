# -*- encoding : utf-8 -*-

require 'wagn/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end


module Wagn
  class Application < Rails::Application
    
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
        
        config.autoload_paths += Dir["#{Wagn.gem_root}/app/**/"]
        config.autoload_paths += Dir["#{Wagn.gem_root}/lib/**/"]
        config.autoload_paths += Dir["#{Wagn.gem_root}/mods/standard/lib/**/"]
        
        config.assets.enabled = true
        config.assets.version = '1.0'
        
        config.filter_parameters += [:password]
        
        config
      end
    end
    

    def paths
      @paths ||= begin
        paths = super
        add_wagn_path paths, 'public'
        add_wagn_path paths, "app",                 :eager_load => true, :glob => "*"
        add_wagn_path paths, "app/assets",          :glob => "*"
        add_wagn_path paths, "app/controllers",     :eager_load => true
        add_wagn_path paths, "app/models",          :eager_load => true
        add_wagn_path paths, "app/mailers",         :eager_load => true
        add_wagn_path paths, "app/views"
#        add_wagn_path paths, "lib",                 :load_path => true
        add_wagn_path paths, "lib/tasks",           :glob => "**/*.rake"
        add_wagn_path paths, "config"
        add_wagn_path paths, "config/environments", :glob => "#{Rails.env}.rb"
        
        add_wagn_path paths, "config/initializers", :glob => "**/*.rb"
        add_wagn_path paths, "config/routes",       :with => "config/routes.rb"
        add_wagn_path paths, "db"
        add_wagn_path paths, "db/migrate"
        add_wagn_path paths, "db/seeds",            :with => "db/seeds.rb"
        
        add_wagn_path paths, 'mods'
        paths['mods'] << 'mods' unless approot_is_gemroot?
        
        paths.add 'files'
        
        paths
      end
    end

    def approot_is_gemroot?
      Wagn.gem_root.to_s == config.root.to_s
    end
    
    def add_wagn_path paths, path, options={}
      wagn_path        = File.join( Wagn.gem_root, path )
      options[:with] &&= File.join( Wagn.gem_root, options[:with]) 
      with = options[:with] || wagn_path
      paths[path] = Rails::Paths::Path.new(paths, wagn_path, with, options)
    end


    
  end
end

