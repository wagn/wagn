class Card
  class View
    # Support context-aware card view caching.
    #
    # View defintions can contain cache settings that guide whether and how
    # the view should be cached.
    #
    #
    module Cache

      def cache_fetch
        cached_view = caching do
          self.class.cache.fetch cache_key do
            @card.register_view_cache_key cache_key
            yield
          end
        end
        return cached_view if self.class.caching?
        @format.stub_render cached_view
      end

      def caching
        self.class.caching(self) { yield }
      end

      def cache_key
        @cache_key ||= [
          @card.key, @format.class, @format.mode, @format.main?,
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

        def fetch cache_key, &block
          send fetch_method, cache_key, &block
        end

        def fetch_method
          @fetch_method ||= begin
            config_option = Card.config.view_cache
            config_option == "debug" ? :verbose_fetch : :standard_fetch
          end
        end

        def canonicalize view
          return if view.blank? # error?
          view.to_viewname.key.to_sym
        end

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
