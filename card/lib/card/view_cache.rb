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

      def count
        Rails.cache.read(CNT_KEY) || 0
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


      def fetch(format, view, args, &block)
        if !Card.config.view_cache || !format.view_caching? || !format.main? ||  (view != :open && view != :content) || format.class != HtmlFormat
          return block.call
        end

        roles = Card::Auth.current.all_roles.join '_'
        key = "view_#{view}_#{format.card.key}_args_#{Card::Cache.obj_to_key(args)}_roles_#{roles}"

        if !Rails.cache.exist?(key)
          increment_cnt
          add_key key
        end

        if count > LIMIT
          reduce_cache
        end

        history = fetch_history
        history[key] ||= 0
        history[key] += 1
        Rails.cache.write(HISTORY_KEY, history)
        status = if Rails.cache.exist? key
          "fetched from cache"
        else
          "wrote to cache"
        end
        cached = Rails.cache.fetch(key, &block)
        "#{status}:#{cached}"
      end

      def reset
        keys.each do |k|
          Rails.cache.delete k
        end
        Rails.cache.write(CNT_KEY, 0)
        Rails.cache.write(KEYS_KEY, ::Set.new)
      end
    end
  end
end