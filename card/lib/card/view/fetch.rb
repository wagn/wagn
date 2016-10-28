class Card
  class View
    # Support context-aware card view caching.
    #
    # View definitions can contain cache settings that guide whether and how
    # the view should be cached.
    module Fetch      # Each of the following keys represents an accepted value for cache
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
        when :cache_yield then cache_fetch(&block)
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
    end
  end
end
