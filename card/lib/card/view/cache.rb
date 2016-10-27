class Card
  class View
    # Support context-aware card view caching.
    #
    # View defintions can contain cache settings that guide whether and how
    # the view should be cached.
    #
    #
    module Cache
      # Each of the following keys represents an accepted value for cache
      # directives on view definitions.  eg:
      #   view :myview, cache: :standard do ...
      #
      # the values represent the default #fetch product to be provided in the
      # context of a "dependent" view caching -- on that is rendered by another
      # view while in the process of being cached.
      DEPENDENT_CACHE_LEVEL = {
        always:   :cache_yield, # always store independent cached view, even if
                                # that means double caching. (eg view is inside
                                # another one already being cached)
        standard: :yield,       # cache independently or dependently, but
                                # don't double cache
        never:    :stub         # don't ever cache this view
      }.freeze

      def fetch &block
        # puts "#{@card.name}/#{requested_view} -> #{ok_view}:" #\
        #      "\n--#{cache_key}"
        #     #      "caching: #{self.class.caching?}"#\
        case cache_level
        when :yield       then yield
        when :cache_yield then cache_fetch &block
        when :stub        then stub
        end
      end

      # "dependent" caching
      # "independent" caching takes place
      def cache_level
        send "#{self.class.caching? ? '' : 'in'}dependent_cache_level"
      end

      def independent_cache_level
        ok_to_cache_independently? ? :cache_yield : :yield
      end

      def ok_to_cache_independently?
        cache_setting != :never && foreign_options.empty? && cache_permissible?
      end

      # The following methods are shared by independent and dependent caching

      def cache_setting
        @format.view_cache_setting requested_view
      end

      # altered view requests and altered cards are not cacheable
      def cache_permissible?
        return false unless requested_view == ok_view
        return false unless permissible_card_state?
        true
      end

      def permissible_card_state?
        return false if @card.unknown?
        return false if @card.db_content_changed?
        # FIXME: might consider other changes as disqualifying, though
        # we should make sure not to disallow caching of virtual cards
        true
      end

      def dependent_cache_level
        level = unvalidated_dependent_cache_level
        validate_stub if level == :stub
        level
      end

      def validate_stub
        return if foreign_options.empty?
        raise "INVALID STUB: #{@card.name}/#{ok_view}" \
              " has foreign options: #{foreign_options}"
      end

      def unvalidated_dependent_cache_level
        return :yield if ok_view == :too_deep
        ok_to_cache_dependently? ? dependent_cache_setting : :stub
      end

      def ok_to_cache_dependently?
        cacheable_nest_name? && cache_nest_permissible?
      end

      def dependent_cache_setting
        DEPENDENT_CACHE_LEVEL[cache_setting]
      end

      def cache_fetch
        cached_view = caching do
          self.class.cache.fetch cache_key do
            @card.register_view_cache_key cache_key
            yield
          end
        end
        return cached_view if self.class.caching?
        @format.stub_render cached_view
      end

      def caching
        self.class.caching(self) { yield }
      end

      def stub
        "<card-view>#{stub_json}</card-view>"
      end

      def stub_json
        JSON.generate stub_array
      end

      def stub_array
        [@card.cast, stub_options, @format.mode, @format.main?]
      end

      def stub_options
        stub_options = options.merge view: requested_view
        stub_visibility_options stub_options
        stub_options
      end

      def stub_visibility_options stub_options
        [:hide, :show].each do |setting|
          stub_options[setting] = viz_hash.keys.select do |k|
            viz_hash[k] == setting
          end.sort.join ","
        end
      end

      def cache_nest_permissible?
        return false unless cache_permissible?
        return true if options[:skip_permissions]
        nestable_view_permissions?
      end

      def nestable_view_permissions?
        case Card::Format.perms[requested_view]
        when :none      then true
        when :read, nil then anyone_can_read?
        else                 false
        end
      end

      def anyone_can_read?
        Card::Auth.as(:anonymous) { @card.ok? :read }
      end

      # names
      def cacheable_nest_name?
        return true if @parent # not directly nested
        case options[:nest_name]
        when "_main" then false
        when "_user" then false
        else true
        end
      end

      def cache_strategy
        Card.config.view_cache
      end

      def cache_key
        @cache_key ||= [
          @card.key, @format.class, @format.mode, @format.main?,
          requested_view, hash_key(options), hash_key(viz_hash)
        ].map(&:to_s).join "-"
      end

      def hash_key hash
        hash.keys.sort.map do |key|
          key_for_option key, hash[key]
        end.join ";"
      end

      def key_for_option key, value
        string_value =
          case value
          when Hash then "{#{hash_key value}}"
          when Array then value.sort.map(&:to_s).join ","
          else value.to_s
          end
        "#{key}:#{string_value}"
      end

      module ClassMethods
        def cache
          Card::Cache[Card::View]
        end

        def caching?
          @caching
        end

        def caching voo
          return yield if @caching
          @caching = voo
          yield
        ensure
          @caching = nil
        end

        def fetch cache_key, &block
          send fetch_method, cache_key, &block
        end

        def fetch_method
          @fetch_method ||= begin
            config_option = Card.config.view_cache
            config_option == "debug" ? :verbose_fetch : :standard_fetch
          end
        end

        def canonicalize view
          return if view.blank? # error?
          view.to_viewname.key.to_sym
        end

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
      end
    end
  end
end
