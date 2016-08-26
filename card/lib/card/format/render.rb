class Card
  class Format
    # View rendering methods.
    #
    module Render
      DEPRECATED_VIEWS = {
        view: :open, card: :open, line: :closed, bare: :core, naked: :core
      }.freeze

      def render view, args={}
        view = canonicalize_view view
        return if hidden_view? view, args
        view = ok_view view, args
        current_view(view) do
          args = default_render_args view, args
          with_nest_mode view do
            Card::Cache::ViewCache.fetch(self, view, args) do
              method = view_method view, args
              method.arity.zero? ? method.call : method.call(args)
            end
          end
        end
      rescue => e
        rescue_view e, view
      end

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
