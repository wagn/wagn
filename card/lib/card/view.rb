require "card/view/visibility"

class Card
  class View
    include Visibility
    class << self
      attr_accessor :active

      def cache
        Card::Cache[View]
      end

      def fetch format, view, args, &block
        key = cache_key view, format, args
        send fetch_method, key, &block
      end

      def fetch_method
        @fetch_method ||= begin
          config_option = Card.config.view_cache
          config_option == "debug" ? :verbose_fetch : :standard_fetch
        end
      end

      def reset
        cache.reset
      end

      def canonicalize view
        return if view.blank? # error?
        view.to_viewname.key.to_sym
      end

      private

      def standard_fetch key, &block
        cache.fetch key, &block
      end

      def verbose_fetch key, &block
        if cache.exist? key
          "fetched from view cache: #{cache.read key}"
        else
          "written to view cache: #{cache.fetch(key, &block)}"
        end
      end

      def cache_key view, format, args
        roles_key = Card::Auth.current.all_roles.sort.join "_"
        args_key = Card::Cache.obj_to_key(args)
        "%s#%s__args__%s__roles__%s" %
          [format.card.key, view, args_key, roles_key]
      end
    end

    def initialize format, view, args={}
      @format = format
      @original = view
      @original_args = args
    end

    def render
      return if hide?
      #      cached_render do
      yield approved, approved_args
      #      end
    end

    def requested
      @requested ||= View.canonicalize @original
    end

    def approved
      @approved ||= @format.ok_view requested, view_args
    end

    def view_args
      @view_args ||= hash_args_from_originals
    end

    def approved_args
      default_method = "default_#{approved}_args"
      if @format.respond_to? default_method
        @format.send default_method, view_args
      end
      view_args
    end

    def hash_args_from_originals
      case (a = @original_args.clone)
      when nil   then {}
      when Hash  then a.clone
      when Array then a[0].merge a[1]
      else raise Card::Error, "bad view args: #{a}"
      end
    end


  end
end
