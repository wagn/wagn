# -*- encoding : utf-8 -*-

require "active_support/core_ext/numeric/time"
djar = "delayed_job_active_record"
require djar if Gem::Specification.find_all_by_name(djar).any?
require "cardio/schema.rb"

ActiveSupport.on_load :card do
  if Card.take
    Card::Mod::Loader.load_mods
  else
    Rails.logger.warn "empty database"
  end
end

module Cardio
  extend Schema
  CARD_GEM_ROOT = File.expand_path("../..", __FILE__)

  mattr_reader :paths, :config

  class << self
    def cache
      @cache ||= ::Rails.cache
    end

    def default_configs
      {
        read_only:              read_only?,
        allow_inline_styles:    false,

        recaptcha_public_key:   nil,
        recaptcha_private_key:  nil,
        recaptcha_proxy:        nil,

        override_host:          nil,
        override_protocol:      nil,

        no_authentication:      false,
        files_web_path:         "files",

        max_char_count:         200,
        max_depth:              20,
        email_defaults:         nil,

        token_expiry:           2.days,
        acts_per_page:          10,
        space_last_in_multispace: true,
        closed_search_limit:    10,
        paging_limit: 20,

        non_createable_types:   [%w(signup setting set)],
        view_cache: false,

        encoding:               "utf-8",
        request_logger:         false,
        performance_logger:     false,
        sql_comments:           true,

        file_storage:           :local,
        file_buckets:           {},
        file_default_bucket: nil
      }
    end

    def set_config config
      @@config = config

      config.autoload_paths += Dir["#{gem_root}/lib/**/"]
      config.autoload_paths += Dir["#{gem_root}/mod/*/lib/**/"]
      config.autoload_paths += Dir["#{root}/mod/*/lib/**/"]

      default_configs.each_pair do |setting, value|
        set_default_value(config, setting, *value)
      end
    end

    def read_only?
      !ENV["WAGN_READ_ONLY"].nil?
    end

    # In production mode set_config gets called twice.
    # The second call overrides all deck config settings
    # so don't change settings here if they already exist
    def set_default_value config, setting, *value
      config.send("#{setting}=", *value) unless config.respond_to? setting
    end

    def set_paths paths
      @@paths = paths
      add_path "tmp/set", root: root
      add_path "tmp/set_pattern", root: root

      add_path "mod"

      add_path "db"
      add_path "db/migrate"
      add_path "db/migrate_core_cards"
      add_path "db/migrate_deck_cards", root: root, with: "db/migrate_cards"
      add_path "db/seeds.rb", with: "db/seeds.rb"

      add_path "config/initializers", glob: "**/*.rb"
      add_initializers root
    end

    def set_mod_paths
      each_mod_path { |mod_path| add_initializers File.join(mod_path, "*") }
    end

    def add_initializers dir
      Dir.glob("#{dir}/config/initializers").each do |initializers_dir|
        paths["config/initializers"] << initializers_dir
      end
    end

    def each_mod_path
      paths["mod"].each do |mod_path|
        yield mod_path
      end
    end

    def root
      @@config.root
    end

    def gem_root
      CARD_GEM_ROOT
    end

    def add_path path, options={}
      root = options.delete(:root) || gem_root
      options[:with] = File.join(root, (options[:with] || path))
      paths.add path, options
    end

    def future_stamp
      # # used in test data
      @future_stamp ||= Time.zone.local 2020, 1, 1, 0, 0, 0
    end

    def migration_paths type
      list = paths["db/migrate#{schema_suffix type}"].to_a
      if type == :deck_cards
        Card::Mod::Loader.mod_dirs.each("db/migrate_cards") do |path|
          list += Dir.glob path
        end
      end

      list.flatten
    end
  end
end
