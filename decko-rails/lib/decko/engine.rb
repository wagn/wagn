
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

DECKO_GEM_ROOT = File.expand_path('../../..', __FILE__)

module Decko

  class Decko::Engine < Rails::Engine

    def paths
      @paths ||= begin
        paths = super

        Decko.add_gem_path paths, "app/controllers",     :eager_load => true

        paths
      end
    end

    def approot_is_gemroot?
      Decko.gem_root.to_s == config.root.to_s
    end

  end

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

    def config
      application.config
    end

    def card_paths_and_config paths
      wpaths = Wagn::Application.paths

      Card.config.read_only             = !!ENV['WAGN_READ_ONLY']
      Card.config.allow_inline_styles   = false

      Card.config.recaptcha_public_key  = nil
      Card.config.recaptcha_private_key = nil
      Card.config.recaptcha_proxy       = nil

      Card.config.cache_store           = :file_store, 'tmp/cache'
      Card.config.override_host         = nil
      Card.config.override_protocol     = nil

      Card.config.no_authentication     = false
      Card.config.files_web_path        = 'files'

      Card.config.email_defaults        = nil

      Card.config.token_expiry          = 2.days
      Card.config.revisions_per_page    = 10

      Wagn::Application.card_config Card.config
      Card.config.database =  Rails.application.config.database_configuration[Rails.env]['database']
      path = wpaths['files'] and paths['files'] = path
      path = wpaths['tmp/set'] and paths['tmp/set'] = path
      path = wpaths['tmp/set_pattern'] and paths['tmp/set_pattern'] = path
      path = wpaths['local-mod'] and paths['local-mod'] = path

      add_gem_path paths, 'gem-mod',             :with => 'mod'
      add_gem_path paths, "db"
      add_gem_path paths, "db/migrate"
      add_gem_path paths, "db/migrate_core_cards"
      add_gem_path paths, 'db/migrate_deck_cards', :with=>'db/migrate_cards'
      add_gem_path paths, "db/seeds",            :with => "db/seeds.rb"

      add_gem_path paths, 'config/initializers', :glob => '**/*.rb'
      paths['config/initializers'].existent.sort.each do |initializer|
        load(initializer)
      end

    end

    def add_gem_path paths, path, options={}
      gem_path = File.join( paths.path, path )
      with = options.delete(:with)
      with = with ? File.join(paths.path, with) : gem_path
      paths[path] = Rails::Paths::Path.new(paths, gem_path, with, options)
    end

  end

end

