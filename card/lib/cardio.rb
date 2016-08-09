# -*- encoding : utf-8 -*-

require "active_support/core_ext/numeric/time"
require "delayed_job_active_record"

module Cardio
  CARD_GEM_ROOT = File.expand_path("../..", __FILE__)

  ActiveSupport.on_load :card do
    if Card.take
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
        closed_search_limit:    50,

        non_createable_types:   [%w(signup setting set)],
        view_cache:             false,

        encoding:               "utf-8",
        request_logger:         false,
        performance_logger:     false,
        sql_comments:           true
      }
    end

    def set_config config
      @@config = config
      @@root = config.root

      config.autoload_paths += Dir["#{gem_root}/mod/*/lib/**/"]
      config.autoload_paths += Dir["#{gem_root}/lib/**/"]
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
      add_path "db/seeds", with: "db/seeds.rb"

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
      @@future_stamp ||= Time.zone.local 2020, 1, 1, 0, 0, 0
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
        ActiveRecord::Schema.assume_migrated_upto_version(
          Cardio.schema(type), Cardio.migration_paths(type)
        )
      end
    end

    def schema_suffix type
      case type
      when :core_cards then "_core_cards"
      when :deck_cards then "_deck_cards"
      else ""
      end
    end

    def delete_tmp_files id=nil
      dir = Cardio.paths["files"].existent.first + "/tmp"
      dir += "/#{id}" if id
      FileUtils.rm_rf dir, secure: true
    rescue
      Rails.logger.info "failed to remove tmp files"
    end

    def schema_mode type
      new_suffix = Cardio.schema_suffix type
      original_suffix = ActiveRecord::Base.table_name_suffix
      ActiveRecord::Base.table_name_suffix = new_suffix
      ActiveRecord::SchemaMigration.reset_table_name
      paths = Cardio.migration_paths(type)
      yield(paths)
      ActiveRecord::Base.table_name_suffix = original_suffix
      ActiveRecord::SchemaMigration.reset_table_name
    end

    def schema type=nil
      File.read(schema_stamp_path type).strip
    end

    def schema_stamp_path type
      root_dir = (type == :deck_cards ? root : gem_root)
      stamp_dir = ENV["SCHEMA_STAMP_PATH"] || File.join(root_dir, "db")

      File.join stamp_dir, "version#{schema_suffix type}.txt"
    end
  end
end
