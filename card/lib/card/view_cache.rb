class Card
  module ViewCache
    class << self
      SIZE = 500
      LIMIT = 1000 # reduce cache size to SIZE if LIMIT is reached
      CNT_KEY = 'view_cache_cnt'
      FREQUENCY_KEY = 'view_cache_frequency'

      def cache
        Card::Cache[Card::ViewCache]
      end

      def increment_cnt
        cache.write(CNT_KEY, count + 1)
      end

      def count
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

      def fetch(format, view, args, &block)
        if !Card.config.view_cache || !format.view_caching? || !format.main? ||  (view != :open && view != :content) || format.class != HtmlFormat
          return block.call
        end

        roles = Card::Auth.current.all_roles.sort.join '_'
        key = "view_#{view}_#{format.card.key}_args_#{Card::Cache.obj_to_key(args)}_roles_#{roles}"

        if !cache.exist?(key)
          increment_cnt
          reduce_cache if count > LIMIT
        end

        update_frequency do |freq|
          freq[key] ||= 0
          freq[key] += 1
        end

        if Card.config.view_cache == 'debug'
          if cache.exist? key
            "fetched from view cache: #{cache.read key}"
          else
            "written to view cache: #{cache.fetch(key, &block)}"
          end
        else
          cache.fetch(key, &block)
        end
      end

      def reset
        cache.reset
      end
    end
  end
end
