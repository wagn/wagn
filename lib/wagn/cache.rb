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
      def initialize_on_startup
        @@preload = false
        if RAILS_ENV =~ /cucumber|test/
          Card.cache = Wagn::Cache.new
          preload_cache_for_tests if preload_cache?
        else
          Card.cache = Wagn::Cache.new Rails.cache
        end
      end
      
      def preload_cache_for_tests
        set_keys = ['*all','basic+*type','html+*type','*cardtype+*type','*sidebar+*self']
        set_keys.map{|k| [k, "#{k}+*content", "#{k}+*default"]}.flatten.each do |key|        
          #Card.fetch key, :skip_after_fetch=>true
        end
        Role[:auth]; Role[:anon]
        @@frozen = Marshal.dump([Card.cache, Role.cache])
      end
      
      def preload_cache?
        @@preload ||= ((RAILS_ENV=='cucumber') || ENV['PRELOAD_CACHE'])
      end

      def system_prefix
        cache_env = (RAILS_ENV == 'cucumber') ? 'test' : RAILS_ENV
        "#{System.host}/#{cache_env}"
      end

      def re_initialize_for_new_request
        Card.cache.system_prefix = system_prefix
        reset_local unless preload_cache?
      end

      def reset_for_tests
        reset_global
        Card.cache, Role.cache = Marshal.load(@@frozen) if preload_cache?
      end

      def generate_cache_id
        ((Time.now.to_f * 100).to_i).to_s + ('a'..'z').to_a[rand(26)] + ('a'..'z').to_a[rand(26)]
      end

      def expire_card(key)
        Card.cache.delete key
      end

      private
      def reset_local
        User.clear_cache if System.multihost
        Cardtype.reset_cache
        Role.reset_cache
        System.reset_cache
        Wagn::Pattern.reset_cache
        Card.cache.reset_local
      end

      def reset_global
        Card.cache.reset
        reset_local
      end
    end

    attr_reader :prefix, :store
    attr_accessor :local

    def initialize(store=nil, system_prefix=nil)
      @store = store
      @local = Hash.new
      self.system_prefix = system_prefix || Wagn::Cache.system_prefix
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
        #        Marshal.load(@store.read(@prefix + key))
        @store.read(@prefix + key)
      end
    end

    def write key, value
      self.write_local(key, value)
      #@store.write(@prefix + key, Marshal.dump(value))  if @store
      @store.write(@prefix + key, value)  if @store
      value
    end

    def write_local key, value
      @local[key] = value
    end

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
      Rails.logger.info "reset_local called"
      @local = {}
    end

    def reset
      Rails.logger.info "reset called"
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
        @local[key] = val
      end
    end
  end
end

