class Card
  module ViewCache
    class << self
      SIZE = 500
      LIMIT = 1000 # reduce cache size to VIEW_CACHE_SIZE if VIEW_CACHE_LIMIT is reached
      CNT_KEY = 'view_cache_cnt'
      HISTORY_KEY = 'view_cache_history'
      KEYS_KEY = 'view_cache_keys'

      def increment_cnt
        if !Rails.cache.exist? CNT_KEY
          Rails.cache.write(CNT_KEY, 0)
        end
        Rails.cache.increment(CNT_KEY)
      end

      def keys
        Rails.cache.read(KEYS_KEY) || ::Set.new
      end
      def add_key key
        Rails.cache.write(KEYS_KEY, (keys << key) )
      end
      def delete_key key
        Rails.cache.write(KEYS_KEY, keys.delete(key) )
      end

      def reduce_cache
        history = fetch_history
        cnts_with_key = history.keys.map { [history[key], key] }
        SortedSet.new(cnts_with_key).each.with_index do |cnt, key, index|
          if index < (VIEW_CACHE_LIMIT - VIEW_CACHE_SIZE)
            Rails.cache.delete(key)
            delete_key key
          else
            history[key] = 0
          end
        end
         Rails.cache.write(HISTORY_KEY, history)
      end

      def fetch_history
        Rails.cache.read(HISTORY_KEY) || {}
      end


      def cache_key obj
        case obj
        when Hash
          obj.sort.map do |key, value|
            "#{key}=>(#{cache_key(value)})"
          end.join ","
        when Array
          obj.map do |value|
            cache_key(value)
          end.join ","
        else
          obj.to_s
        end
      end

      def fetch(format, view, args, &block)
        if !format.view_caching? || view != :open || format.class != HtmlFormat
          return block.call
        end

        role =
          if Card::Auth.current_id == AnonymousID
            AnonymousID
          elsif Card::Auth.current.all_roles == [AnyoneSignedInID]
            AnyoneSignedInID
          end

        return block.call unless role

        key = "view_#{view}_#{format.card.key}_#{cache_key(args)}_#{role}"

        if !Rails.cache.exist?(key)
          increment_cnt
          add_key key
        end

        if Rails.cache.read(CNT_KEY) > LIMIT
          reduce_cache
        end

        history = fetch_history
        history[key] ||= 0
        history[key] += 1
        Rails.cache.write(HISTORY_KEY, history)
        Rails.cache.fetch(key, &block)
      end

      def reset
        keys.each do |k|
          Rails.cache.delete k
        end
        Rails.cache.write(KEYS_KEY, ::Set.new)
      end
    end
  end
end