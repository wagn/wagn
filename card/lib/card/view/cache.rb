class Card
  class View
    module Cache
      attr_accessor :active

      def cache
        Card::Cache[Card::View]
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
  end
end