class Card
  class View
    # Support context-aware card view caching.
    #
    # View definitions can contain cache settings that guide whether and how
    # the view should be cached.
    module Fetch
      # fetching can result in one of three things:
      # - simply yielding the initial render call
      # - storing or retrieving the render to/from the cache
      # - creating a stub within another render
      #   (so that the stub may be rendered later)
      def fetch &block
        with_fetch_logging do |cache_level|
          case cache_level
          when :yield       then yield
          when :cache_yield then cache_fetch(&block)
          when :stub        then stub
          end
        end
      end

      # Each of the following represents an accepted value for cache
      # directives on view definitions.  eg:
      #   view :myview, cache: :standard do ...
      #
      # * *always* - store independent cached view, even if that means double
      #   caching. (eg view is inside another one already being cached)
      # * *standard* (default) cache independently or dependently, but
      #   don't double cache
      # * *never* don't ever cache this view
      def determine_cache_level
        return :yield unless Cardio.config.view_cache
        send "#{caching? ? 'dependent' : 'independent'}_cache_level"
      end

      def with_fetch_logging
        cache_level = determine_cache_level
        logging = false # TODO: make configurable
        if logging
          puts "FETCH_VIEW (#{card.name}##{requested_view})" \
               "cache-level = #{cache_level}"
        end
        yield cache_level
      end

      # INDEPENDENT CACHING
      # takes place on its own (not within another view being cached)

      def independent_cache_level
        independent_cache_ok? ? :cache_yield : :yield
      end

      def independent_cache_ok?
        cache_setting != :never &&
          foreign_live_options.empty? &&
          clean_enough_to_cache?
      end

      # The following methods are shared by independent and dependent caching

      # view-specific setting as set in view definition. (always, standard, or
      # never)
      def cache_setting
        format.view_cache_setting requested_view
      end

      # altered view requests and altered cards are not cacheable
      def clean_enough_to_cache?
        requested_view == ok_view &&
          !card.unknown? &&
          !card.db_content_changed?
        # FIXME: might consider other changes as disqualifying, though
        # we should make sure not to disallow caching of virtual cards
      end

      # DEPENDENT CACHING
      # handling of views rendered within another cached view.

      def dependent_cache_level
        level = dependent_cache_level_unvalidated
        validate_stub if level == :stub
        level
      end

      def dependent_cache_level_unvalidated
        return :yield if ok_view == :too_deep
        dependent_cache_ok? ? dependent_cache_setting : :stub
      end

      def dependent_cache_ok?
        return false unless parent && clean_enough_to_cache?
        return true if normalized_options[:skip_perms]
        dependent_cacheable_permissible?
      end

      def dependent_cacheable_permissible?
        case permission_task
        when :none                  then true
        when parent.permission_task then true
        when Symbol                 then card.anyone_can?(permission_task)
        else                             false
        end
      end

      # task directly associated with the view in its definition via the
      # "perms" directive
      def permission_task
        @permission_task ||= Card::Format.perms[requested_view] || :read
      end

      DEPENDENT_CACHE_LEVEL =
        { always: :cache_yield, standard: :yield, never: :stub }.freeze

      def dependent_cache_setting
        level = DEPENDENT_CACHE_LEVEL[cache_setting]
        level || raise("unknown cache setting: #{cache_setting}")
      end
    end
  end
end
