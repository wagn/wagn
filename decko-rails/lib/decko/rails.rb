DECKO_RAILS_GEM_ROOT = File.expand_path("../../..", __FILE__)

require "rails/all"
require "decko/engine"

module Decko
  module Rails # not sure we need this
    class << self
      def gem_root
        DECKO_RAILS_GEM_ROOT
      end
    end
  end

  if defined? ::Rails::Railtie
    class Railtie < ::Rails::Railtie
      initializer "decko-rails.load_task_path", before: "decko.engine.load_config_initializers" do
        Cardio.set_config ::Rails.application.config
        Cardio.set_paths ::Rails.application.paths
      end

      rake_tasks do |_app|
        begin
          # for some reason this needs the 'wagn/', can't get lib/tasks change right by this time?
          load "wagn/tasks/wagn.rake"
          load "card/tasks/card.rake"
        end
      end
    end
  end
end
