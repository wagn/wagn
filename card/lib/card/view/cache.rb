class Card
  class View
    # cache mechanics for view caching
    module Cache
      # adds tracking, mapping, and stub handling to standard cache fetching
      def cache_fetch
        cached_view = caching do
          self.class.cache.fetch cache_key do
            card.register_view_cache_key cache_key
            yield
          end
        end
        caching? ? cached_view : format.stub_render(cached_view)
      end

      # tracks that a cache fetch is in progress
      def caching
        self.class.caching(self) { yield }
      end

      # answers: should this cache fetch depend on one already in progress?
      # Note that f you create a brand new format object (ie, not a subformat)
      # midrender, (eg card.format...), it needs to be treated as unrelated to
      # any caching in progress.
      def caching?
        root? ? false : self.class.caching?
      end

      # neither view nor format has a parent
      def root?
        !parent && !format.parent
      end

      def cache_key
        @cache_key ||= [
          card.key, format.class, format.mode, options_for_cache_key
        ].map(&:to_s).join "-"
      end

      def options_for_cache_key
        hash_for_cache_key(live_options) + hash_for_cache_key(viz_hash)
      end

      def hash_for_cache_key hash
        hash.keys.sort.map do |key|
          option_for_cache_key key, hash[key]
        end.join ";"
      end

      def option_for_cache_key key, value
        string_value =
          case value
          when Hash then "{#{hash_for_cache_key value}}"
          when Array then value.sort.map(&:to_s).join ","
          else value.to_s
          end
        "#{key}:#{string_value}"
      end

      # cache-related Card::View class methods
      module ClassMethods
        def cache
          Card::Cache[Card::View]
        end

        def caching?
          @caching
        end

        def caching voo
          old_caching = @caching
          @caching = voo
          yield
        ensure
          @caching = old_caching
        end
      end
    end
  end
end
