# -*- encoding : utf-8 -*-

require 'rails'
require 'active_support/core_ext/numeric/time'

class CardRailtie < Rails::Railtie
  class << self
    def paths
      @@paths
    end

    def config
      @@config
    end
  end

  initializer 'card.insert_into_active_record' do
    ActiveSupport.on_load :active_record do
      if defined?(ActiveRecord) && !defined?(Card)
        ActiveRecord::Base.establish_connection(Rails.env) #Rails.application.config.database_configuration[Rails.env])
        require_dependency 'card' unless defined?(Card)
      end
    end
    ActiveSupport.on_load :card do
      Card::Loader.load_mods if Card.count > 0
    end
  end

  def add_card_paths paths, config
    @@config = config
    @@paths = paths

    config.read_only             = !!ENV['WAGN_READ_ONLY']
    config.allow_inline_styles   = false

    config.recaptcha_public_key  = nil
    config.recaptcha_private_key = nil
    config.recaptcha_proxy       = nil

    config.cache_store           = :file_store, 'tmp/cache'
    config.override_host         = nil
    config.override_protocol     = nil

    config.no_authentication     = false
    config.files_web_path        = 'files'

    config.email_defaults        = nil

    config.token_expiry          = 2.days
    config.revisions_per_page    = 10

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
    gem_path = File.join( CARD_GEM_ROOT, path )
    with = options.delete(:with)
    with = with ? File.join(CARD_GEM_ROOT, with) : gem_path
    #warn "add gem path #{path} gp:#{gem_path}, w:#{with}, o:#{options.inspect}"
    paths[path] = Rails::Paths::Path.new(paths, gem_path, with, options)
  end

end
