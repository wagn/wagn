
require 'rails/all'

require 'htmlentities'
require 'recaptcha'
require 'airbrake'
require 'RMagick'
require 'paperclip'
require 'coderay'
require 'haml'
require 'kaminari'
require 'diff/lcs'
require 'diffy'
#require 'scheduler_daemon'

CARD_GEM_ROOT = File.expand_path('../../..', __FILE__)

class Card < ActiveRecord::Base

  class << self
    def root
      Rails.root
    end
  
    def gem_root
      CARD_GEM_ROOT
    end

    def config
      Rails.application.config
    end

    def paths
      config.paths
    end
    
    def future_stamp
      ## used in test data
      @@future_stamp ||= Time.local 2020,1,1,0,0,0
    end
  end
    
  class Engine < Rails::Engine

    initializer :load_card_config_initializers,  :before => :load_config_initializers do
      add_gem_path paths, 'lib/card/config/initializers', :glob => "**/*.rb"
      config.paths['lib/card/config/initializers'].existent.sort.each do |initializer|
        load(initializer)
      end
    end

    def paths
      @paths ||= begin
        paths = super
        add_gem_path paths, 'gem-mod',             :with => 'mod'

        add_gem_path paths, "app/controllers",     :eager_load => true
        add_gem_path paths, "db"
        add_gem_path paths, "db/migrate"
        add_gem_path paths, "db/migrate_core_cards"
        add_gem_path paths, "db/seeds",            :with => "db/seeds.rb"
        add_gem_path paths, 'gem-mod',             :with => 'mod'
        add_gem_path paths, 'gem-assets',          :with => 'public/assets'

        paths
      end
    end
    
    def approot_is_gemroot?
      Card.gem_root.to_s == config.root.to_s
    end

    def add_gem_path paths, path, options={}
      gem_path = File.join( Card.gem_root, path )
      with = options.delete(:with)
      with = with ? File.join(Card.gem_root, with) : gem_path
      #warn "add gem path #{path}, #{with}, #{gem_path}, #{options.inspect}"
      paths[path] = Rails::Paths::Path.new(paths, gem_path, with, options)
    end

  end

end

