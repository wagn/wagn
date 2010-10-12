module Wagn
  mattr_accessor :cache

  module Cache
    class << self
      def initialize_on_startup
        Card.cache = Wagn::Cache::Main.new Rails.cache, "#{System.host}/#{RAILS_ENV}"
      end

      def re_initialize_for_new_request
        CachedCard.set_cache_prefix "#{System.host}/#{RAILS_ENV}"
        initialize_on_startup
        reset_local
      end

      def reset_for_tests
        reset_global
        CachedCard.set_cache_prefix "#{System.host}/cucumber"
        CachedCard.bump_global_seq
        CachedCard.set_cache_prefix "#{System.host}/test"
        CachedCard.bump_global_seq
      end

      private
      def reset_local
        User.clear_cache if System.multihost
        Cardtype.reset_cache
        Role.reset_cache
        System.reset_cache
        Wagn::Pattern.reset_cache
        CachedCard.reset_cache
        Card.cache.reset_local
      end

      def reset_global
        CachedCard.bump_global_seq
        Card.cache.reset
        reset_local
      end

    end

    class Base
      attr_reader :prefix, :local

      def initialize(store, prefix)
        @store = store
        @local = Hash.new
        @prefix = prefix + '/'
      end

      def read key
#        p "reading #{key}"
        fetch_local(key) do
#          p "reading #{key} from @store"
          @store.read(@prefix + key)
        end
      end

      def write key, value
#        p "Cache writing #{key}, #{value.inspect[0..30]}"
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

      def dump
        p "dumping local...."
        @local.each do |k,v|
          p "#{k} --> #{v.inspect[0..30]}"
        end
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
    end
  end
end

Card.send :mattr_accessor, :cache
