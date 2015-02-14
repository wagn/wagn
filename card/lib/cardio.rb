# -*- encoding : utf-8 -*-

require 'rails'
require 'active_support/core_ext/numeric/time'

CARD_GEM_ROOT = File.expand_path('../..', __FILE__)

module Cardio

  ActiveSupport.on_load :card do
    Card::Loader.load_mods if Card.count > 0
  end

  class << self
    def paths
      @@paths
    end

    def config
      @@config
    end

    def root
      @@root
    end

    def gem_root
      CARD_GEM_ROOT
    end

    def add_card_paths paths, config, root
      @@config = config
      @@paths = paths
      @@root = root

      config.read_only             = !!ENV['WAGN_READ_ONLY']
      config.allow_inline_styles   ||= false

      config.recaptcha_public_key  ||= nil
      config.recaptcha_private_key ||= nil
      config.recaptcha_proxy       ||= nil

      config.cache_store           ||= :file_store, 'tmp/cache'
      config.override_host         ||= nil
      config.override_protocol     ||= nil

      config.no_authentication     ||= false
      config.files_web_path        ||= 'files'

      config.max_char_count        ||= 200
      config.max_depth             ||= 20
      config.email_defaults        ||= nil

      config.token_expiry          ||= 2.days
      config.revisions_per_page    ||= 10
      config.closed_search_limit   ||= 50

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
      gem_path = File.join( gem_root, path )
      with = options.delete(:with)
      with = with ? File.join(gem_root, with) : gem_path
      #warn "add gem path #{path} gp:#{gem_path}, w:#{with}, o:#{options.inspect}"
      paths[path] = Rails::Paths::Path.new(paths, gem_path, with, options)
    end

    def future_stamp
      ## used in test data
      @@future_stamp ||= Time.local 2020,1,1,0,0,0
    end

    def delete_tmp_files id=nil
      dir = Cardio.paths['files'].existent.first + '/tmp'
      dir += "/#{id}" if id
      FileUtils.rm_rf dir, :secure=>true
    rescue
      Rails.logger.info "failed to remove tmp files"
    end
  end
end

