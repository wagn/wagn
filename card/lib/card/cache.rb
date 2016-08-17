# -*- encoding : utf-8 -*-

class Card
  class Cache
    extend Card::Cache::Prepopulate

    @prepopulating = %w(test cucumber).include? Rails.env
    @no_rails_cache = %w(test cucumber).include?(Rails.env) ||
                      ENV["NO_RAILS_CACHE"]
    @@cache_by_class = {}
    cattr_reader :cache_by_class

    class << self
      # create a new cache for the ruby class provided
      # @param klass [Class]
      # @return [{Card::Cache}]
      def [] klass
        raise "nil klass" if klass.nil?
        cache_type = (@no_rails_cache ? nil : Cardio.cache)
        cache_by_class[klass] ||= new class: klass,
                                      store: cache_type
      end

      # establish clean context;
      # clear the temporary caches and ensure we're using the latest stamp
      # on the persistent caches.
      def renew
        cache_by_class.each do |_klass, cache|
          cache.soft.reset
          cache.hard.renew if cache.hard
        end
      end

      # reset all caches for all classes
      def reset_all
        reset_hard
        reset_soft
        reset_other
      end

      # completely wipe out all caches, often including the Persistent cache of
      # other decks using the same mechanism.
      # Generally prefer {#reset_all}
      # @see #reset_all
      def reset_global
        cache_by_class.each do |_klass, cache|
          cache.soft.reset
          cache.hard.annihilate if cache.hard
        end
        reset_other
      end

      # reset the Persistent cache for all classes
      def reset_hard
        cache_by_class.each do |_klass, cache|
          cache.hard.reset if cache.hard
        end
      end

      # reset the Temporary cache for all classes
      def reset_soft
        cache_by_class.each do |_klass, cache|
          cache.soft.reset
        end
      end

      # reset Codename cache and delete tmp files
      # (the non-standard caches)
      def reset_other
        Card::Codename.reset_cache
        Cardio.delete_tmp_files
      end

      # generate a cache key from an object
      # @param obj [Object]
      # @return [String]
      def obj_to_key obj
        case obj
        when Hash
          obj.sort.map { |key, value| "#{key}=>(#{obj_to_key(value)})" } * ","
        when Array
          obj.map { |value| obj_to_key(value) }
        else
          obj.to_s
        end
      end
    end

    attr_reader :hard, :soft

    def initialize opts={}
      @klass = opts[:class]
      cache_by_class[@klass] = self
      @hard = Persistent.new opts if opts[:store]

      # soft cache is temporary
      # lasts only one request/script execution/console session
      @soft = Temporary.new
    end

    def read key
      @soft.read(key) ||
        (@hard && (ret = @hard.read(key)) && @soft.write(key, ret))
    end

    def write key, value
      @hard.write key, value if @hard
      @soft.write key, value
    end

    def fetch key, &block
      @soft.fetch(key) do
        @hard ? @hard.fetch(key, &block) : yield
      end
    end

    def delete key
      @hard.delete key if @hard
      @soft.delete key
    end

    def dump
      p "dumping temporary request cache...."
      @soft.dump
    end

    def reset
      @hard.reset if @hard
      @soft.reset
    end

    def exist? key
      @soft.exist?(key) || (@hard && @hard.exist?(key))
    end
  end
end

# ActiveSupport::Cache::FileStore.class_eval do
#   # escape special symbols \*"<>| additionaly to :?.
#   # All of them not allowed to use in ms windows file system
#   def real_file_path name
#     name = name.gsub("%", "%25").gsub("?", "%3F").gsub(":", "%3A")
#     name = name.gsub('\\', "%5C").gsub("*", "%2A").gsub('"', "%22")
#     name = name.gsub("<", "%3C").gsub(">", "%3E").gsub("|", "%7C")
#     "%s/%s.cache" % [@cache_path, name]
#   end
# end
