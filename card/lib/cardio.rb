# -*- encoding : utf-8 -*-

require 'rails'
require 'active_support/core_ext/numeric/time'

CARD_GEM_ROOT = File.expand_path('../..', __FILE__)

module Cardio

  ActiveSupport.on_load :card do
    Card::Loader.load_mods if Card.count > 0
  end

  mattr_reader :paths, :config, :root, :cache

  class << self
    def card_config *args
      @@config, @@paths, @@root, @@cache = args

      config.read_only             = !!ENV['WAGN_READ_ONLY']
      config.allow_inline_styles   = false                    unless config.respond_to? :allow_inline_styles

      config.recaptcha_public_key  = nil                      unless config.respond_to? :recaptcha_public_key
      config.recaptcha_private_key = nil                      unless config.respond_to? :recaptcha_private_key
      config.recaptcha_proxy       = nil                      unless config.respond_to? :recaptcha_proxy

      config.cache_store           = :file_store, 'tmp/cache' unless config.respond_to? :cache_store
      config.override_host         = nil                      unless config.respond_to? :override_host
      config.override_protocol     = nil                      unless config.respond_to? :override_protocol

      config.no_authentication     = false                    unless config.respond_to? :no_authentication
      config.files_web_path        = 'files'                  unless config.respond_to? :files_web_path

      config.max_char_count        = 200                      unless config.respond_to? :max_char_count
      config.max_depth             = 20                       unless config.respond_to? :max_depth
      config.email_defaults        = nil                      unless config.respond_to? :email_defaults

      config.token_expiry          = 2.days                   unless config.respond_to? :token_expiry
      config.revisions_per_page    = 10                       unless config.respond_to? :revisions_per_page
      config.closed_search_limit   = 50                       unless config.respond_to? :closed_search_limit

      add_gem_path paths, 'gem-mod',             :with => 'mod'
      add_gem_path paths, "db"
      add_gem_path paths, 'db/migrate'
      add_gem_path paths, "db/migrate_core_cards"
      add_gem_path paths, "db/seeds",            :with => "db/seeds.rb"

      add_gem_path paths, 'config/initializers', :glob => '**/*.rb'
      paths['config/initializers'].existent.sort.each do |initializer|
        load(initializer)
      end
    end

    def gem_root
      CARD_GEM_ROOT
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

    def migration_paths type
      paths["db/migrate#{schema_suffix type}"].to_a
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

