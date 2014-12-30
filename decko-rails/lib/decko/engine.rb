
require 'rails/all'
require 'card_railtie'

# TODO: Move these to modules that use them
require 'htmlentities'
require 'recaptcha'
require 'airbrake'
require 'coderay'
require 'haml'
require 'kaminari'
require 'diff/lcs'
require 'diffy'

DECKO_GEM_ROOT = File.expand_path('../../..', __FILE__)

module Decko

  class << self
    def root
      Rails.root
    end

    def gem_root
      DECKO_GEM_ROOT
    end

    def application
      Rails.application
    end

    def add_gem_path paths, path, options={}
      gem_path = File.join( Decko.gem_root, path )
      with = options.delete(:with)
      with = with ? File.join(paths.path, with) : gem_path
      paths[path] = Rails::Paths::Path.new(paths, gem_path, with, options)
    end

  end

  class Decko::Engine < Rails::Engine

    Decko.add_gem_path paths, "app/controllers",     :eager_load => true

    ActiveSupport.on_load(:active_record) do
      CardRailtie.add_card_paths Decko::Engine.paths, Rails.application.config
    end

  end
end

