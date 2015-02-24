
require 'rails/all'
require 'cardio'

# TODO: Move these to modules that use them
require 'htmlentities'
require 'recaptcha'
require 'airbrake'
require 'coderay'
require 'haml'
require 'kaminari'
require 'diff/lcs'
require 'diffy'


module Wagn
  class Engine < ::Rails::Engine

    paths.add "app/controllers", :with => 'rails/controllers', :eager_load => true
    paths.add 'gem-assets',      :with => 'rails/assets'
    paths.add 'config/routes',   :with => 'rails/engine-routes.rb'
    paths.add 'lib/tasks',       :with => 'lib/wagn/tasks', :glob => '**/*.rake'
    

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        if defined? Wagn
          #this code should all be in Wagn somewhere, I suspect.
          Wagn::Engine.paths['request_log'] = Wagn.paths['request_log']
          Wagn::Engine.paths['log']         = Wagn.paths['log']
        else
          Cardio.card_config ::Rails.application.config
        end
        Cardio.cache == ::Rails.cache
        
        ActiveRecord::Base.establish_connection(::Rails.env)
      end
      ActiveSupport.on_load(:after_initialize) do
        begin
          require_dependency 'card' unless defined?(Card)
        rescue ActiveRecord::StatementInvalid => e
          ::Rails.logger.warn "database not available[#{::Rails.env}] #{e}"
        end
      end
    end

  end
end

