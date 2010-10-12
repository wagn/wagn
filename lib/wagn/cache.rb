module Wagn
  mattr_accessor :cache

  module Cache
    class << self
      def reset_local
        User.clear_cache if System.multihost
        Cardtype.reset_cache
        Role.reset_cache
        System.reset_cache
        Wagn::Pattern.reset_cache
        CachedCard.reset_cache
      end

      def reset_global
        CachedCard.bump_global_seq
      end
    end

    class Base
      attr_reader :prefix

      def initialize(store, prefix)
        @store = store
        @local = Hash.new
        @prefix = prefix + '/'
      end

      def read key
        fetch_local(key) do
          @store.read(@prefix + key)
        end
      end

      def write key, value
        @local[key] = value
        @store.write(@prefix + key, value)
      end

      def fetch key, &block
        fetch_local(key) do
          @store.fetch(@prefix + key, &block)
        end
      end

      def delete key
        @local.delete key
        @store.delete(@prefix + key)
      end

      def reset_local
        @local = {}
      end

      private
      def fetch_local key
        if @local.has_key?(key)
          @local[key]
        else
          val = yield
          @local[key] = val
        end
      end
    end

    class Main < Base
      def initialize(store, prefix)
        @store = store
        @local = Hash.new
        @original_prefix = prefix + '/'
        @cache_id = @store.fetch(@original_prefix + "cache_id") do
          self.class.generate_cache_id
        end
        @prefix = @original_prefix + @cache_id + "/"
      end

      def reset
        reset_local
        @cache_id = self.class.generate_cache_id
        @store.write(@original_prefix + "cache_id", @cache_id)
        @prefix = @original_prefix + @cache_id + "/"
      end

      def self.generate_cache_id
        ((Time.now.to_f * 100).to_i).to_s + ('a'..'z').to_a[rand(26)] + ('a'..'z').to_a[rand(26)]
      end
    end

    def self.expire_card(key)
      Card.cache.delete key
     # legacy
      begin
        Card.fetch(key).expire_all
      rescue
      end
    end
  end
end

Card.send :mattr_accessor, :cache
