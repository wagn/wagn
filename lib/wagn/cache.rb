module Wagn


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
    Klasses = [Card, User, Card::Revision ]

    @@prepopulating     = Rails.env == 'cucumber'
    @@using_rails_cache = Rails.env =~ /^cucumber|test$/
    @@prefix_root       = Wagn::Application.config.database_configuration[Rails.env]['database']

    class << self
      def new_all
        store = @@using_rails_cache ? nil : Rails.cache
        Klasses.each do |cc|
          cc.cache = new :class=>cc, :store=>store
        end
        prepopulate if @@prepopulating
      end

      def renew
        Klasses.each do |cc|
          if cc.cache
              cc.cache.system_prefix = system_prefix(cc)
          else
            raise "renewing nil cache: #{cc}"
          end
        end
        reset_local unless @@prepopulating
      end

      def system_prefix klass
        "#{ @@prefix_root }/#{ klass }"
      end

      def restore
        reset_local
        if @@prepopulating
          Card.cache = Marshal.load @@frozen
        end
      end

      def generate_cache_id
        ((Time.now.to_f * 100).to_i).to_s + ('a'..'z').to_a[rand(26)] + ('a'..'z').to_a[rand(26)]
      end

      def reset_global
        Klasses.each do |cc|
          next unless cache = cc.cache
          cache.reset hard=true
        end
        Wagn::Codename.reset_cache
      end

      private


      def prepopulate
        set_keys = ['*all','*all plus','basic+*type','html+*type','*cardtype+*type','*sidebar']
        set_keys.map{|k| [k,"#{k}+*content", "#{k}+*default", "#{k}+*read", ]}.flatten.each do |key|
          Card[key]
        end
        @@frozen = Marshal.dump(Card.cache)
      end

      def reset_local
        Klasses.each{ |cc|
          if Wagn::Cache===cc.cache
          cc.cache && cc.cache.reset_local
          else warn "reset class #{cc}, #{cc.cache.class} #{caller[0..8]*"\n"} ???" end
        }
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
        @prefix = @system_prefix + @cache_id + "/"
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

    def reset hard=false
      reset_local
      @cache_id = self.class.generate_cache_id
      if @store
        if hard
          @store.clear
        else
          @store.write @system_prefix + "cache_id", @cache_id
        end
      end
      @prefix = @system_prefix + @cache_id + "/"
    end

    private
    def fetch_local key
      if @local.has_key?(key)
        @local[key]
      else
        val = yield
        val.reset_mods if val.respond_to?(:reset_mods)
        #why does this happen here?
        @local[key] = val
      end
    end
  end
end

