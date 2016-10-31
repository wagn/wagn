class Card
  class View
    # cache mechanics for view caching
    module Cache
      def cache_fetch
        cached_view = caching do
          self.class.cache.fetch cache_key do
            @card.register_view_cache_key cache_key
            yield
          end
        end
        return cached_view if caching?
        @format.stub_render cached_view
      end

      def caching
        self.class.caching(self) { yield }
      end

      def caching?
        self.class.caching?
      end

      def cache_key
        @cache_key ||= [
          @card.key,
          @format.class,
          @format.mode,
          requested_view,
          hash_for_cache_key(normalized_options)
        ].map(&:to_s).join "-"
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
          return yield if @caching
          @caching = voo
          yield
        ensure
          @caching = nil
        end
      end
    end
  end
end
