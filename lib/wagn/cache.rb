module Wagn
  require 'tempfile'

  Tempfile.class_eval do
    # overwrite tempfiles implementation of attachment_fu. FIXME: why n is nil?
    def make_tmpname(basename, n)
      ext = nil
      n = 0 if n.nil?
      sprintf("%s%d-%d%s", basename.to_s.gsub(/\.\w+$/) { |s| ext = s; '' }, $$, n, ext)
    end
  end

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
    
    class << self
      def cache_classes
        [Card, Cardtype, MultihostMapping, Role, User]
      end
            
      def initialize_on_startup
        cache_classes.each do |cc|
          cc.cache = new :class=>cc, :store=>(Rails.env =~ /^cucumber|test$/ ? nil : Rails.cache)
        end
        preload_cache_for_tests if preload_cache?
      end
      
      def preload_cache?
        Rails.env=='cucumber'
      end
      
      def preload_cache_for_tests
        return unless preload_cache?
        set_keys = ['*all','*all plus','basic+*type','html+*type','*cardtype+*type','*sidebar+*self']
        set_keys.map{|k| [k,"#{k}+*content", "#{k}+*default", "#{k}+*read", ]}.flatten.each do |key|        
          Card[key]
        end
        Role[:auth]; Role[:anon]
        @@frozen = Marshal.dump([Card.cache, Role.cache])
      end
      
      def system_prefix(klass)
        cache_env = (Rails.env == 'cucumber') ? 'test' : Rails.env
        "#{Wagn::Conf[:host]}/#{cache_env}/#{klass}"
      end

      def re_initialize_for_new_request
        cache_classes.each do |cc|
          cc.cache.system_prefix = system_prefix(cc)
        end
        reset_local unless preload_cache?
      end

      def reset_for_tests
        reset_local
        Card.cache, Role.cache = Marshal.load(@@frozen) if preload_cache?
      end

      def generate_cache_id
        ((Time.now.to_f * 100).to_i).to_s + ('a'..'z').to_a[rand(26)] + ('a'..'z').to_a[rand(26)]
      end

      def expire_card(key)
        Card.cache.delete key
      end

      def reset_global
        cache_classes.each{ |cc| cc.cache.reset }
        MultihostMapping.reset_cache
      end

      private
      def reset_local
        cache_classes.each{ |cc| cc.cache.reset_local }
      end

    end

    attr_reader :prefix, :store
    attr_accessor :local

    def initialize(opts={})
      #@klass = opts[:class]
      @store = opts[:store]
      @local = Hash.new
      self.system_prefix = opts[:prefix] || self.class.system_prefix(opts[:class])
    end

    def system_prefix=(system_prefix)
      @system_prefix = system_prefix
      if @store.nil?
        @prefix = system_prefix + self.class.generate_cache_id + "/"
      else
        @system_prefix += '/' unless @system_prefix[-1] == '/'
        @cache_id = @store.fetch(@system_prefix + "cache_id") do
          self.class.generate_cache_id
        end
        @prefix   = @system_prefix + @cache_id + "/"
      end
    end

    def read key
      return @local[key] unless @store
      fetch_local(key) do
        @store.read(@prefix + key)
      end
    end

    def write key, value
      self.write_local(key, value)
      #@store.write(@prefix + key, Marshal.dump(value))  if @store
      @store.write(@prefix + key, value) if @store
      value
    end
    
    def write_local(key, value) @local[key] = value end
    def read_local(key)         @local[key]         end

    def fetch key, &block
      fetch_local(key) do
        if @store
          @store.fetch(@prefix + key, &block)
        else
          block.call
        end
      end
    end

    def delete key
      @local.delete key
      @store.delete(@prefix + key)  if @store
    end

    def dump
      p "dumping local...."
      @local.each do |k, v|
        p "#{k} --> #{v.inspect[0..30]}"
      end
    end

    def reset_local
      @local = {}
    end

    def reset
      reset_local
      @cache_id = self.class.generate_cache_id
      @store.write(@system_prefix + "cache_id", @cache_id)  if @store
      @prefix = @system_prefix + @cache_id + "/"
    end

    private
    def fetch_local key
      if @local.has_key?(key)
        @local[key]
      else
        val = yield
        val.reset_mods if val.respond_to?(:reset_mods)
        @local[key] = val
      end
    end
  end
end

