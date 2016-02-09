class Card::Format
  module Render
    def page view, slot_opts
      @card.run_callbacks :show_page do
        show view, slot_opts
      end
    end

    def render view, args={}
      view = canonicalize_view view
      return if hidden_view? view, args
      view = ok_view view, args
      current_view(view) do
        args = default_render_args view, args
        with_inclusion_mode view do
          Card::ViewCache.fetch(self, view, args) do
            method = view_method view, args
            method.arity == 0 ? method.call : method.call(args)
          end
        end
      end
    rescue => e
      rescue_view e, view
    end

    def view_method view, args
      method "_view_#{view}"
    rescue
      args[:unsupported_view] = view
      method '_view_unsupported_view'
    end

    def hidden_view? view, args
      args.delete(:optional) && !show_view?(view, args)
    end

    def show_view? view, args
      default = args.delete(:default_visibility) || :show # FIXME: - ugly
      api_option = args["optional_#{view}".to_sym]
      case
      # permanent visibility specified in code
      when api_option == :always then true
      when api_option == :never  then false
      else
        # wagneer can override code settings
        contextual_setting = nest_arg_visibility(view, args) || api_option
        case contextual_setting
        when :show               then true
        when :hide               then false
        else default == :show
        end
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
        else       raise Card::Error, "bad render args: #{a}"
        end

      default_method = "default_#{view}_args"
      if respond_to? default_method
        send default_method, args
      end
      args
    end

    def rescue_view e, view
      if Rails.env =~ /^cucumber|test$/
        raise e
      else
        Rails.logger.info "\nError rendering #{error_cardname} / #{view}: "\
                          "#{e.class} : #{e.message}"
        Card::Error.current = e
        card.notable_exception_raised
        if (debug = Card[:debugger]) && debug.content == 'on'
          raise e
        else
          rendering_error e, view
        end
      end
    end

    def current_view view
      old_view = @current_view
      @current_view = view
      yield
    ensure
      @current_view = old_view
    end

    def error_cardname
      card && card.name.present? ? card.name : 'unknown card'
    end

    def rendering_error _exception, view
      "Error rendering: #{error_cardname} (#{view} view)"
    end

    def add_class options, klass
      options[:class] = [options[:class], klass].flatten.compact * ' '
    end

    def unique_id
      "#{card.key}-#{Time.now.to_i}-#{rand(3)}"
    end
  end
end