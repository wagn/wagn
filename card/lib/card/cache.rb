# -*- encoding : utf-8 -*-

class Card

  ActiveSupport::Cache::FileStore.class_eval do
    # escape special symbols \*"<>| additionaly to :?.
    # All of them not allowed to use in ms windows file system
    def real_file_path(name)
      name = name.gsub('%','%25').gsub('?','%3F').gsub(':','%3A')
      name = name.gsub('\\','%5C').gsub('*','%2A').gsub('"','%22')
      name = name.gsub('<','%3C').gsub('>','%3E').gsub('|','%7C')
      '%s/%s.cache' % [@cache_path, name ]
    end
  end

  class Cache

    TEST_ENVS         = %w{test cucumber}
    @@prepopulating   = TEST_ENVS.include? Rails.env
    @@no_rails_cache  = TEST_ENVS.include?(Rails.env) || ENV['NO_RAILS_CACHE']
    @@cache_by_class  = {}

    cattr_reader :cache_by_class

    class << self
      def [] klass
        raise "nil klass" if klass.nil?
        cache_by_class[klass] ||= new class: klass, store: (@@no_rails_cache ? nil : Cardio.cache)
      end

      def renew
        cache_by_class.keys do |klass|
          if klass.cache
            cache_by_class[klass].system_prefix = system_prefix(klass)
          else
            raise "renewing nil cache: #{klass}"
          end
        end
        reset_local
      end

      def prefix_root
        @@prefix_root ||= ( cfg = Cardio.config and cfg = cfg.database_configuration and
                            cfg[Rails.env]['database'] )
      end

      def system_prefix klass
        "#{ prefix_root }/#{ klass }"
      end

      def restore klass=nil
        reset_local
        prepopulate
      end

      def generate_cache_id
        ((Time.now.to_f * 100).to_i).to_s + ('a'..'z').to_a[rand(26)] + ('a'..'z').to_a[rand(26)]
      end

      def reset_global
        cache_by_class.each do |klass, cache|
          cache.reset hard=true
        end
        Card::Codename.reset_cache
        Cardio.delete_tmp_files
      end

      def reset_local
        cache_by_class.each do |cc, cache|
          if Card::Cache===cache
            cache.reset_local
          else warn "reset class #{cc}, #{cache.class} #{caller[0..8]*"\n"} ???" end
        end
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
        if @@prepopulating
          @@rule_cache      ||= Card.rule_cache
          @@read_rule_cache ||= Card.read_rule_cache
          @@user_ids_cache  ||= Card.user_ids_cache
          @@rule_keys_cache ||= Card.rule_keys_cache
          Card.cache.write_local 'RULES', @@rule_cache
          Card.cache.write_local 'READRULES', @@read_rule_cache
          Card.cache.write_local 'USER_IDS', @@user_ids_cache
          Card.cache.write_local 'RULE_KEYS', @@rule_keys_cache
        end
      end



    end

    attr_reader :prefix, :store, :klass
    attr_accessor :local

    def initialize opts={}
      #warn "new cache #{opts.inspect}"
      @klass = opts[:class]
      @store = opts[:store]
      @local = Hash.new
      self.system_prefix = opts[:prefix] || self.class.system_prefix(opts[:class])
      cache_by_class[klass] = self
    end


    def system_prefix= system_prefix
      @system_prefix = system_prefix
      if @store.nil?
        @prefix = system_prefix + self.class.generate_cache_id + "/"
      else
        @system_prefix += '/' unless @system_prefix[-1] == '/'
        @cache_id = @store.fetch(@system_prefix + "cache_id") do
          self.class.generate_cache_id
        end
        @prefix = @system_prefix + @cache_id + "/"
      end
    end

    def read key
      if @local.has_key? key
        read_local key
      elsif @store
        write_local key, @store.read(@prefix + key)
      end
    end

    def read_local key
      @local[key]
    end

    def write_variable key, variable, value
      key = @prefix + key
      if @store and object = @store.read(key)
        object.instance_variable_set "@#{ variable }", value
        @store.write key, object
      end
      value
    end

    def write key, value
      @store.write(@prefix + key, value) if @store
      write_local key, value
    end

    def write_local key, value
      @local[key] = value
    end

    def fetch key, &block
      fetch_local key do
        if @store
          @store.fetch(@prefix + key, &block)
        else
          block.call
        end
      end
    end

    def fetch_local key
      read_local key or write_local key, yield
    end

    def delete key
      @store.delete(@prefix + key) if @store
      @local.delete key
    end

    def dump
      p "dumping local...."
      @local.each do |k, v|
        p "#{k} --> #{v.inspect[0..30]}"
      end
    end

    def reset hard=false
      reset_local
      @cache_id = self.class.generate_cache_id
      if @store
        if hard
          begin
            @store.clear
          rescue => e
            Rails.logger.debug "Problem clearing cache: #{e.message}"
          end
        else
          @store.write @system_prefix + "cache_id", @cache_id
        end
      end
      @prefix = @system_prefix + @cache_id + "/"
    end

    def reset_local
      @local = {}
    end

    def exist? key
      @local.has_key?(key) || (@store && @store.exist?(key))
    end
  end
end

