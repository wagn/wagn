class Card
  class View
    module Cache

      def fetch &block
        case (level = cache_level)
        when :off  then yield
        when :full then cache_fetch(&block)
        when :stub then stub_nest
        else raise "Invalid cache level #{level}"
        end
      end

      def stub_nest view, args
        # binding.pry
        "<card-nest/>"
      end

      def cache_level
        return :off unless Card.config.view_cache
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
        format.view_cache_permissible? approved, options
      end

      def cache_setting
        format.view_cache_setting
      end


      # "default" means not in the context of a nest within an active
      # cache result
      def cache_default_level
        cache_setting == :always && cache_permissible? ? :full : :off
      end

      # names
      def cacheable_nest_name? name
        case name
        when "_main" then main?
        when "_user" then false
        else true
        end
      end

      def cache_fetch
        self.class.progressively do
          cached_view = fetch cache_key, &block
          cache_strategy == :client ? cached_view : complete_render(cached_view)
        end
      end

      def cache_strategy
        Card.config.view_cache
      end

      def cache_key
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