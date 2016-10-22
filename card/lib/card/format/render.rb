class Card
  class Format
    # View rendering methods.
    #
    module Render
      # API
      # `view cache: [:always, :nested, :never]
      # :always means a view is always cached when rendered

      # :nested means a view is not cached independently,
      # but it can be cached within another view
      # :never means a view is never cached

      def render view, args={}
        voo = View.new self, view, args, @voo
        with_voo(voo) do
          voo.prepare do |final_view, final_args|
            final_render final_view, final_args
          end
        end
      rescue => e
        rescue_view e, view
      end

      def with_voo voo
        old_voo = @voo
        @voo = voo
        result = yield
        @voo = old_voo
        result
      end

      def view_options_with_defaults view, options
        default_method = "default_#{view}_args"
        send default_method, options if respond_to? default_method
        options
      end

      def voo
        @voo ||= View.new(self, :noview)
      end

      def show_view? view, default_viz=:show
        voo.optional? # triggers visibility processing
        visibility = voo.viz_hash[view] || default_viz
        visibility == :show
      end

      def final_render view, args
        current_view(view) do
          with_nest_mode view do
            method = view_method view, args
            method.arity.zero? ? method.call : method.call(args)
          end
        end
      end

      # setting (:alway, :never, :nested) designated in view definition
      def view_cache_setting view
        setting_method = self.class.view_cache_setting_method view
        respond_to?(setting_method) ? send(setting_method) : :always
      end

      # for now, permit only if "Anyone" can read card and see view
      # later add support for caching restricted views nested by other views
      # with the same restrictions
      def view_cache_permissible? view, args
        Card::Auth.as(:anonymous) do
          card.ok?(:read) && ok_view(view, args)
        end
      end

      def complete_cached_view_render cached_content
        expand_stubs cached_content do |card, options|
          nest card, options
        end
      end

      def expand_stubs cached_content
        conto = Card::Content.new cached_content, self, chunk_list: :stub
        conto.process_each_chunk do |card, options|
          yield(card, options).to_s
        end
        conto.to_s
      end

      def api_render match, opts
        view = match[3] ? match[4] : opts.shift
        args = opts[0] ? opts.shift.clone : {}
        optional_render_args(args, opts) if match[2]
        args[:skip_permissions] = true if match[1]
        render view, args
      end

      def optional_render_args args, opts
        args[:optional] = opts.shift || :show
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
