class Card
  module ViewCache
    class << self
      SIZE = 500
      LIMIT = 1000 # reduce cache size to SIZE if LIMIT is reached
      CNT_KEY = "view_cache_cnt".freeze
      FREQUENCY_KEY = "view_cache_frequency".freeze

      def cache
        Card::Cache[Card::ViewCache]
      end

      def fetch format, view, args, &block
        return yield unless cacheable_view?(view, format)

        key = cache_key view, format, args
        update_cache_accounting! key

        if Card.config.view_cache == "debug"
          verbose_fetch key, &bloack
        else
          cache.fetch key, &block
        end
      end

      def reset
        cache.reset
      end

      private

      def update_cache_accounting! key
        unless cache.exist?(key)
          increment_cached_views_cnt
          reduce_cache if cached_views_cnt > LIMIT
        end
        increment_frequency key
      end

      def verbose_fetch
        if cache.exist? key
          "fetched from view cache: #{cache.read key}"
        else
          "written to view cache: #{cache.fetch(key, &block)}"
        end
      end

      def increment_cached_views_cnt
        cache.write(CNT_KEY, cached_views_cnt + 1)
      end

      def cached_views_cnt
        cache.read(CNT_KEY) || 0
      end

      def reduce_cache
        update_frequency do |freq|
          cnts_with_key = freq.keys.map { |key| [freq[key], key] }
          index = 1
          SortedSet.new(cnts_with_key).each do |_cnt, key|
            if index < (LIMIT - SIZE)
              cache.delete(key)
              freq.delete(key)
            else
              freq[key] = 0
            end
            index += 1
          end
        end
      end

      def update_frequency
        freq = cache.read(FREQUENCY_KEY) || {}
        yield(freq)
        cache.write(FREQUENCY_KEY, freq)
      end

      def increment_frequency key
        update_frequency do |freq|
          freq[key] ||= 0
          freq[key] += 1
        end
      end

      def cache_key view, format, args
        roles_key = Card::Auth.current.all_roles.sort.join "_"
        args_key = Card::Cache.obj_to_key(args)
        "%s#%s__args__%s__roles__%s" %
          [format.card.key, view, args_key, roles_key]
      end

      def cacheable_view? view, format
        Card.config.view_cache &&
          format.view_caching? &&
          format.main? &&
          format.class == HtmlFormat &&
          (view == :open || view == :content)
      end
    end
  end
end
