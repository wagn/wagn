class Card
  class View
    module Cache
      CACHE_SETTING_NEST_LEVEL =
        { always: :full, nested: :off, never: :stub }.freeze

      def fetch &block
        level = cache_level
        # puts "cache level #{level.to_s.upcase} :: "\
        #     " #{@card.name}/#{original_view}"
        case level
        when :off  then yield
        when :full then cache_fetch(&block)
        when :stub then stub_nest
        else raise "Invalid cache level #{level}"
        end
      end

      def stub_nest
        "<card-nest>#{stub_json}</card-nest>"
      end

      def stub_json
        JSON(stub_hash)
      end

      def stub_hash
        normalized_options.merge view: original_view
      end

      def cache_level
        return :off # unless Card.config.view_cache
        level_method = self.class.in_progress? ? :cache_nest : :cache_default
        send "#{level_method}_level"
      end

      def cache_nest_level
        if cacheable_nest_name? && cache_permissible?
          CACHE_SETTING_NEST_LEVEL[cache_setting]
        else
          :stub
        end
      end

      def cache_permissible?
        return false unless ok_view == original_view
        @format.view_cache_permissible? original_view, options
      end

      def cache_setting
        @format.view_cache_setting original_view
      end

      # "default" means not in the context of a nest within an active
      # cache result
      def cache_default_level
        ok_to_cache_independently? ? :full : :off
      end

      def ok_to_cache_independently?
        cache_setting == :always &&
          non_standard_options.empty? &&
          cache_permissible?
      end

      # names
      def cacheable_nest_name?
        case options[:nest_name]
        when "_main" then @format.main?
        when "_user" then false
        else true
        end
      end

      def cache_fetch &block
        self.class.progressively do
          #cached_view = Card::View.cache.fetch cache_key, &block
          cached_view = block.call
          @format.complete_cached_view_render cached_view

          #cache_strategy == :client ? cached_view : complete_render(cached_view)
        end
      end

      def cache_strategy
        Card.config.view_cache
      end

      def cache_key
        "#{@card.key}-#{original_view}-#{options}"
      end

      def complete_render cached_view
        cached_view
        # use Card::Content to process nest stubs
      end

      module ClassMethods
        def cache
          Card::Cache[Card::View]
        end

        def fetch view, &block
          actively do
            cached_view = fetch self, view, args, &block
            # cache_strategy == :client ? cached_view :
            complete_render(cached_view)
          end
        end

        def cache_strategy
          Card.config.view_cache
        end

        def in_progress?
          @in_progress
        end

        def progressively
          return yield if @in_progress
          @in_progress = true
          result = yield
          @in_progress = false
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