class Card
  class Format
    # View rendering methods.
    #
    module Render
      CACHE_SETTING_NEST_LEVEL =
        { always: :full, nested: :off, never: :stub }.freeze

      # API
      # `view cache: [:always, :nested, :never]
      # :always means a view is always cached when rendered

      # :nested means a view is not cached independently,
      # but it can be cached within another view
      # :never means a view is never cached

      def render view, args={}
        View.new(self, view, args).render do |final_view, final_args|
          final_render final_view, final_args
        end
      rescue => e
        rescue_view e, view
      end

      #
      # def voo
      #
      # end
      #
      # def render view, args={}
      #   voo = new_voo(view) unless view.is_a? View
      #   voo.with(args).render do |final_view|
      #     final_render final_view
      #   end
      # rescue => e
      #   rescue_view e, view
      # end
      #

      def final_render view, args
        current_view(view) do
          with_nest_mode view do
            method = view_method view, args
            method.arity.zero? ? method.call : method.call(args)
          end
        end
      end

      def cache_render view, args, &block
        case (level = cache_level viewo)
        when :off  then yield viewo
        when :full then cached_result viewo, &block
        when :stub then stub_nest viewo
        else raise "Invalid cache level #{level}"
        end
      end

      def stub_nest view, args
        # binding.pry
        "<card-nest/>"
      end

      def cache_level viewo
        return :off unless Card.config.view_cache
        level_method = cache_render_in_progress? ? :cache_nest : :cache_default
        send "#{level_method}_level", viewo
      end

      def cache_render_in_progress?
        Card::View.in_progress
      end

      def cache_nest_level view
        if view.cacheable_nest_name? && view.cache_permissible?
          CACHE_SETTING_NEST_LEVEL[view.cache_setting]
        else
          :stub
        end
      end

      # "default" means not in the context of a nest within an active
      # cache result
      def cache_default_level view
        if view.cache_setting == :always && view.cache_permissible?
          :full
        else
          :off
        end
      end

      # setting (:alway, :never) designated in view definition
      def view_cache_setting view, args
        setting_method = "view_#{view}_cache_setting"
        respond_to?(setting_method) ? send(setting_method, args) : :always
      end

      # names
      def cacheable_nest_name? name
        case name
        when "_main" then main?
        when "_user" then false
        else true
        end
      end

      # for now, permit only if "Anyone" can read card and see view
      # later add support for caching restricted views nested by other views
      # with the same restrictions
      def cache_permissible? view, args
        Card::Auth.as(:anonymous) do
          card.ok?(:read) && ok_view(view, args)
        end
      end

      def cached_result view, args, &block
        active_view_cache do
          cached_view = Card::View.fetch self, view, args, &block
          cache_strategy == :client ? cached_view : complete_render(cached_view)
        end
      end

      def active_view_cache
        vc = Card::View
        return yield if vc.active
        vc.active = true
        result = yield
        vc.active = false
        result
      end

      def cache_strategy
        Card.config.view_cache
      end

      def complete_render cached_view
        cached_view
        # use Card::Content to process nest stubs
      end

      def api_render match, opts
        view = match[3] ? match[4] : opts.shift
        args = opts[0] ? opts.shift.clone : {}
        optional_render_args(args, opts) if match[2]
        args[:skip_permissions] = true if match[1]
        render view, args
      end

      def optional_render_args args, opts
        args[:optional] = true
        args[:default_visibility] = opts.shift
      end

      def view_method view, args
        method "_view_#{view}"
      rescue
        args[:unsupported_view] = view
        method "_view_unsupported_view"
      end

      def current_view view
        old_view = @current_view
        @current_view = view
        yield
      ensure
        @current_view = old_view
      end
    end
  end
end
