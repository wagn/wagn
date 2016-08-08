
require "rails/all"
require "cardio"

# TODO: Move these to modules that use them
require "htmlentities"
require "recaptcha"
require "coderay"
require "haml"
require "kaminari"
require "bootstrap-kaminari-views"
require "diff/lcs"
require "builder"

require "wagn"

module Decko
  class Engine < ::Rails::Engine
    paths.add "app/controllers",  with: "rails/controllers", eager_load: true
    paths.add "gem-assets",       with: "rails/assets"
    paths.add "config/routes.rb", with: "rails/engine-routes.rb"
    paths.add "lib/tasks", with: "#{::Wagn.gem_root}/lib/wagn/tasks",
                           glob: "**/*.rake"
    paths["lib/tasks"] << "#{::Cardio.gem_root}/lib/card/tasks"
    paths.add "lib/wagn/config/initializers",
              with: File.join(Wagn.gem_root, "lib/wagn/config/initializers"),
              glob: "**/*.rb"

    initializer "decko.engine.load_config_initializers",
                after: :load_config_initializers do
      paths["lib/wagn/config/initializers"].existent.sort.each do |initializer|
        load(initializer)
      end
    end

    initializer "engine.copy_configs",
                before: "decko.engine.load_config_initializers" do
      # this code should all be in Wagn somewhere, and it is now, gem-wize
      # Ideally railties would do this for us; this is needed for both use cases
      Engine.paths["request_log"]   = Wagn.paths["request_log"]
      Engine.paths["log"]           = Wagn.paths["log"]
      Engine.paths["lib/tasks"]     = Wagn.paths["lib/tasks"]
      Engine.paths["config/routes"] = Wagn.paths["config/routes"]
    end

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
      ActiveSupport.on_load(:after_initialize) do
        begin
          require_dependency "card" unless defined?(Card)
        rescue ActiveRecord::StatementInvalid => e
          ::Rails.logger.warn "database not available[#{::Rails.env}] #{e}"
        end
      end
    end
  end
end
