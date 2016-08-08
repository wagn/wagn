# -*- encoding : utf-8 -*-

class Card
  class Cache
    TEST_ENVS         = %w(test cucumber).freeze
    @@prepopulating   = TEST_ENVS.include? Rails.env
    @@no_rails_cache  = TEST_ENVS.include?(Rails.env) || ENV["NO_RAILS_CACHE"]
    @@cache_by_class  = {}

    cattr_reader :cache_by_class

    class << self
      def [] klass
        raise "nil klass" if klass.nil?
        cache_type = (@@no_rails_cache ? nil : Cardio.cache)
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

      def restore
        reset_soft
        prepopulate
      end

      def reset_global
        cache_by_class.each do |_klass, cache|
          cache.soft.reset
          cache.hard.annihilate if cache.hard
        end
        reset_other
      end

      def reset_all
        reset_hard
        reset_soft
        reset_other
      end

      def reset_hard
        cache_by_class.each do |_klass, cache|
          cache.hard.reset if cache.hard
        end
      end

      def reset_soft
        cache_by_class.each do |_klass, cache|
          cache.soft.reset
        end
      end

      def reset_other
        Card::Codename.reset_cache
        Cardio.delete_tmp_files
      end

      def obj_to_key obj
        case obj
        when Hash
          obj.sort.map do |key, value|
            "#{key}=>(#{obj_to_key(value)})"
          end.join ","
        when Array
          obj.map do |value|
            obj_to_key(value)
          end.join ","
        else
          obj.to_s
        end
      end

      private

      def prepopulate
        return unless @@prepopulating
        soft = Card.cache.soft
        @@rule_cache ||= Card.rule_cache
        @@user_ids_cache ||= Card.user_ids_cache
        @@read_rule_cache ||= Card.read_rule_cache
        @@rule_keys_cache ||= Card.rule_keys_cache
        soft.write "RULES", @@rule_cache
        soft.write "READRULES", @@read_rule_cache
        soft.write "USER_IDS", @@user_ids_cache
        soft.write "RULE_KEYS", @@rule_keys_cache
      end
    end

    attr_reader :hard, :soft

    def initialize opts={}
      @klass = opts[:class]
      cache_by_class[@klass] = self

      # hard cache mirrors the db
      # only difference to db: it caches virtual cards
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
        if @hard
          @hard.fetch(key, &block)
        else
          yield
        end
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

ActiveSupport::Cache::FileStore.class_eval do
  # escape special symbols \*"<>| additionaly to :?.
  # All of them not allowed to use in ms windows file system
  def real_file_path name
    name = name.gsub("%", "%25").gsub("?", "%3F").gsub(":", "%3A")
    name = name.gsub('\\', "%5C").gsub("*", "%2A").gsub('"', "%22")
    name = name.gsub("<", "%3C").gsub(">", "%3E").gsub("|", "%7C")
    "%s/%s.cache" % [@cache_path, name]
  end
end
