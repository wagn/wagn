# -*- encoding : utf-8 -*-

require 'active_support/core_ext/numeric/time'

CARD_GEM_ROOT = File.expand_path('../..', __FILE__)

module Cardio

  ActiveSupport.on_load :card do
    if Card.count > 0
      Card::Loader.load_mods 
    else
      Rails.logger.warn "empty database"
    end
  end

  mattr_reader :paths, :config, :cache

  class << self
    def cache
      @@cache ||= ::Rails.cache
    end
    
    def set_config config
      @@config, @@root = config, config.root

      config.autoload_paths += Dir["#{gem_root}/mod/*/lib/**/"]
      config.autoload_paths += Dir["#{gem_root}/lib/**/"]
      config.autoload_paths += Dir["#{root}/mod/*/lib/**/"]

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

      config.max_char_count        = 200
      config.max_depth             = 20
      config.email_defaults        = nil

      config.token_expiry          = 2.days
      config.revisions_per_page    = 10
      config.closed_search_limit   = 50
    end

  
    def set_paths paths
      @@paths = paths
      add_path 'tmp/set', :root => root
      add_path 'tmp/set_pattern', :root => root

      add_path 'mod'
      add_path "db"
      add_path 'db/migrate'
      add_path "db/migrate_core_cards"
      add_path "db/migrate_deck_cards", :root => root, :with => 'db/migrate_cards'
      add_path "db/seeds", :with => "db/seeds.rb"

      add_path 'config/initializers', :glob => '**/*.rb'
    end

    def root
      @@config.root
    end
    
    def gem_root
      CARD_GEM_ROOT
    end

    def add_path path, options={}
      root = options.delete(:root) || gem_root
      gem_path = File.join( root, path )
      with = options.delete(:with)
      with = with ? File.join(root, with) : gem_path
      paths[path] = Rails::Paths::Path.new(paths, gem_path, with, options)
    end

    def future_stamp
      ## used in test data
      @@future_stamp ||= Time.local 2020,1,1,0,0,0
    end

    def migration_paths type
      list = paths["db/migrate#{schema_suffix type}"].to_a
      if type == :deck_cards
        list += Card::Loader.mod_dirs.map do |p|
          Dir.glob "#{p}/db/migrate_cards"
        end.flatten
      end
      list
    end

    def assume_migrated_upto_version type
      Cardio.schema_mode(type) do
        ActiveRecord::Schema.assume_migrated_upto_version Cardio.schema(type), Cardio.migration_paths(type)
      end
    end

    def schema_suffix type
      case type
      when :core_cards then '_core_cards'
      when :deck_cards then '_deck_cards'
      else ''
      end
    end

    def delete_tmp_files id=nil
      dir = Cardio.paths['files'].existent.first + '/tmp'
      dir += "/#{id}" if id
      FileUtils.rm_rf dir, :secure=>true
    rescue
      Rails.logger.info "failed to remove tmp files"
    end

    def schema_mode type
      new_suffix = Cardio.schema_suffix type
      original_suffix = ActiveRecord::Base.table_name_suffix

      ActiveRecord::Base.table_name_suffix = new_suffix
      yield
      ActiveRecord::Base.table_name_suffix = original_suffix
    end

    def schema type=nil
      File.read( schema_stamp_path type ).strip
    end

    def schema_stamp_path type
      root_dir = ( type == :deck_cards ? root : gem_root )
      stamp_dir = ENV['SCHEMA_STAMP_PATH'] || File.join( root_dir, 'db' )

      File.join stamp_dir, "version#{ schema_suffix(type) }.txt"
    end

  end
end

