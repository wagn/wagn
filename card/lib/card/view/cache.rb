class Card
  class View
    module Cache
      CACHE_SETTING_NEST_LEVEL =
        { always: :full, standard: :off, nested: :off, never: :stub }.freeze

      def fetch &block
        level = cache_level
        #puts "#{@card.name}/#{requested_view} -> #{ok_view}:" #\
        #     "\n--#{cache_key}"
        #     #      "in_progress: #{self.class.in_progress?}"#\

       #       "\n--nonstandard=#{foreign_options}#"
       #      # " depth = #{@format.instance_variable_get '@depth'}"
        case level
        when :off  then yield
        when :full then cache_fetch(&block)
        when :stub then stub_nest
        else raise "Invalid cache level #{level}"
        end
      end

      def cache_fetch &block
        cached_view = progressively do
          self.class.cache.fetch cache_key, &block
        end
        return cached_view if self.class.in_progress?
        @format.complete_cached_view_render cached_view
      end

      def progressively
        self.class.progressively(self) { yield }
      end

      def stub_nest
        "<card-view>#{stub_json}</card-view>"
      end

      def stub_json
        JSON.generate stub_array
      end

      def stub_array
        [@card.cast, stub_options, @format.mode]
      end

      def stub_options
        stub_options = options.merge view: requested_view
        stub_visibility_options stub_options
        stub_options
      end

      def stub_visibility_options stub_options
        [:hide, :show].each do |setting|
          stub_options[setting] = viz_hash.keys.select do |k|
            viz_hash[k] == setting
          end.sort.join ","
        end
      end

      def cache_level
        # return :off # unless Card.config.view_cache
        level_method =
          self.class.in_progress? ? :cache_nest : :cache_independent
        send "#{level_method}_level"
      end

      def cache_nest_level
        level =
          if ok_view == :too_deep
            :off
          elsif cacheable_nest_name? && cache_nest_permissible?
            CACHE_SETTING_NEST_LEVEL[cache_setting]
          else
            :stub
          end
        validate_nest_cache! level
      end

      def validate_nest_cache! level
        return level unless level == :stub && foreign_options.any?
        raise "INVALID NEST CACHE: #{@card.name}/#{ok_view}" \
              " has foreign options: #{foreign_options}"
      end

      def cache_permissible?
        return false unless requested_view == ok_view
        return false unless permissible_card_state?
        true
      end

      def cache_nest_permissible?
        return false unless cache_permissible?
        return true if options[:skip_permissions]
        nestable_view_permissions?
      end

      def permissible_card_state?
        return false if @card.unknown?
        return false if @card.db_content_changed?
        # FIXME: might consider other changes as disqualifying, though
        # we should make sure not to disallow caching of virtual cards
        true
      end

      def nestable_view_permissions?
        case Card::Format.perms[requested_view]
        when :none      then true
        when :read, nil then anyone_can_read?
        else                 false
        end
      end

      def anyone_can_read?
        Card::Auth.as(:anonymous) { @card.ok? :read }
      end

      def cache_setting
        @format.view_cache_setting requested_view
      end

      # "default" means not in the context of a nest within an active
      # cache result
      def cache_independent_level
        ok_to_cache_independently? ? :full : :off
      end

      def ok_to_cache_independently?
        cache_setting.in?([:always, :standard]) &&
          foreign_options.empty? &&
          cache_permissible?
      end

      # names
      def cacheable_nest_name?
        return true if @parent # not directly nested
        case options[:nest_name]
        when "_main" then false
        when "_user" then false
        else true
        end
      end

      def cache_strategy
        Card.config.view_cache
      end

      def cache_key
        [
          @card.key, @format.class, @format.mode,
          requested_view, hash_key(options), hash_key(viz_hash)
        ].map(&:to_s).join "-"
      end

      def hash_key hash
        hash.keys.sort.map do |key|
          key_for_option key, hash[key]
        end.join ";"
      end

      def key_for_option key, value
        string_value =
          case value
          when Hash then "{#{hash_key value}}"
          when Array then value.sort.map(&:to_s).join ","
          else value.to_s
          end
        "#{key}:#{string_value}"
      end

      module ClassMethods
        def cache
          Card::Cache[Card::View]
        end

        def in_progress?
          @in_progress
        end

        def progressively voo
          return yield if @in_progress
          @in_progress = voo
          result = yield
          @in_progress = nil
          result
        end

        def fetch cache_key, &block
          send fetch_method, cache_key, &block
        end

        def fetch_method
          @fetch_method ||= begin
            config_option = Card.config.view_cache
            config_option == "debug" ? :verbose_fetch : :standard_fetch
          end
        end

        def reset
          cache.reset
        end

        def canonicalize view
          return if view.blank? # error?
          view.to_viewname.key.to_sym
        end

        private

        def standard_fetch key, &block
          cache.fetch key, &block
        end

        def verbose_fetch key, &block
          if cache.exist? key
            "fetched from view cache: #{cache.read key}"
          else
            "written to view cache: #{cache.fetch(key, &block)}"
          end
        end
      end
    end
  end
end
