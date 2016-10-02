class Card
  class Format
    # View rendering methods.
    #
    module Render
      DEPRECATED_VIEWS = {
        view: :open, card: :open, line: :closed, bare: :core, naked: :core
      }.freeze

      CACHE_SETTING_NEST_LEVEL = {
        always: :full, nested: :off, never: :stub
      }.freeze

      # API
      # `view cache: [:always, :nested, :never]
      # :always means a view is always cached when rendered

      # :nested means a view is not cached independently, but it can be cached within another view
      # :never means a view is never cached



      def render view, args={}
        return unless (view = renderable_view view, args)
        args = default_render_args view, args
        cache_render view, args do
          render! view, args
        end
      rescue => e
        rescue_view e, view
      end

      def render! view, args
        current_view(view) do
          with_nest_mode view do
            method = view_method view, args
            method.arity.zero? ? method.call : method.call(args)
          end
        end
      end

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
        # write me.
      end

      def cache_nest_level view, args
        return :stub unless cacheable_nest_name? args
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

        # use Card::Content to process nest stubs
      end

      def renderable_view view, args
        view = canonicalize_view view
        return false if hidden_view? view, args
        ok_view view, args
      end

      # FIXME: would have method name conflict with render method for view :api
      def render_api match, opts
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

      def canonicalize_view view
        return if view.blank?
        view_key = view.to_viewname.key.to_sym
        DEPRECATED_VIEWS[view_key] || view_key
      end

      def default_item_view
        :name
      end

      def hidden_view? view, args
        args.delete(:optional) && !show_view?(view, args)
      end

      def show_view? view, args
        code_config = args["optional_#{view}".to_sym]
        case code_config
          # permanent visibility specified in code
        when :always then true
        when :never  then false
        else configured_visibility view, args, code_config
        end
      end

      def configured_visibility view, args, code_config
        card_config = nest_arg_visibility view, args
        case (card_config || code_config)
        when :show then true
        when :hide then false
        else
          default_viz = args.delete :default_visibility
          default_viz ? default_viz == :show : true
        end
      end

      def nest_arg_visibility view, args
        [:show, :hide].each do |setting|
          return setting if parse_view_visibility(args[setting]).member?(view)
        end
        false
      end

      def parse_view_visibility val
        case val
        when NilClass then []
        when Array    then val
        when String   then val.split(/[\s,]+/)
        else raise Card::Error, "bad show/hide argument: #{val}"
        end.map { |view| canonicalize_view view }
      end

      def default_render_args view, a=nil
        args =
          case a
          when nil   then {}
          when Hash  then a.clone
          when Array then a[0].merge a[1]
          else raise Card::Error, "bad render args: #{a}"
          end

        default_method = "default_#{view}_args"
        send default_method, args if respond_to?(default_method)
        args
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
