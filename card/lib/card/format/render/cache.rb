class Card
  class Format
    module Render

      # render cache API
      # `view cache: [:always, :nested, :never]
      # :always means a view is always cached when rendered
      # :nested means a view is not cached independently,
      #    but it can be cached within another view
      # :never means a view is never cached
      module Cache
        CACHE_SETTING_NEST_LEVEL = {
          always: :full, nested: :off, never: :stub
        }.freeze

        def cache_render view, args, &block
          case (level = cache_level view, args)
          when :off  then yield view, args
          when :full then cached_result view, args, &block
          when :stub then stub_nest view, args
          else raise "Invalid cache level #{level}"
          end
        end

        def cache_level view, args
          return :off unless Card.config.view_cache
          if cache_render_in_progress?
            cache_nest_level view, args
          else
            cache_default_level view, args
          end
        end

        def cache_render_in_progress?
          false
          # write me.
        end

        def cache_nest_level view, args
          return :stub unless cacheable_nest_name?(args) &&
                              cache_permissible?(view, args)
          CACHE_SETTING_NEST_LEVEL[view_cache_setting(view, args)]
        end

        # "default" means not in the context of a nest within an active
        # cache result
        def cache_default_level view, args
          return :off if view_cache_setting(view, args) == :never
          return :off unless cache_permissible? view, args
          :full
        end

        # get setting determined in view definition
        def view_cache_setting view, args
          setting_method = "view_#{view}_cache_setting"
          if respond_to? setting_method
            send setting_method, args
          else
            :always
          end
        end

        # names
        def cacheable_nest_name? args
          case args[:inc_name]
          when "_main" then main?
          when "_user" then false
          else true
          end
        end

        def cache_permissible? view, args
          Card::Auth.as(:anonymous) do
            card.ok?(:read) && ok(view, args)
          end
          # for now, permit only if "Anyone" can read card and see view
          # later add support for caching restricted views nested by other views
          # with the same restrictions
        end

        def cached_result view, args, &block
          cached_view = Card::Cache::ViewCache.fetch self, view, args, &block
          cache_strategy = Card.config.view_cache
          cache_strategy == :client ? cached_view : complete_render(cached_view)
        end

        def complete_render content_with_nest_stubs
          content_with_nest_stubs
          # use Card::Content to process nest stubs
        end

      end
    end
  end
end