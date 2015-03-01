
require 'rails/all'
require 'activerecord/session_store'
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


module Decko
  class Engine < ::Rails::Engine

    paths.add "app/controllers", :with => 'rails/controllers', :eager_load => true
    paths.add 'gem-assets',      :with => 'rails/assets'
    paths.add 'config/routes',   :with => 'rails/engine-routes.rb'
    paths.add 'lib/tasks',       :with => 'lib/wagn/tasks', :glob => '**/*.rake'
    

    initializer :connect_on_load do
      Cardio.cache == ::Rails.cache
      ActiveSupport.on_load(:active_record) do
        if defined? Wagn
          #this code should all be in Wagn somewhere, I suspect.
          Engine.paths['request_log'] = Wagn.paths['request_log']
          Engine.paths['log']         = Wagn.paths['log']
        else
          Cardio.card_config ::Rails.application.config
        end
        
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

