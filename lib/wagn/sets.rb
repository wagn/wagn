

module Wagn

  # pre-declare the root of the Modules namespace tree
  module Set
  end

  module Sets
    @@dirs = []

    module SharedMethods
    end
    module ClassMethods
    end

    def self.included base

      #base.extend CardControllerMethods
      base.extend SharedMethods
      base.extend ClassMethods

      super

    end

    module SharedMethods
      private
      def get_set_key selection_key, opts
        unless pkey = Cardlib::Pattern.method_key(opts)
          raise "bad method_key opts: #{pkey.inspect} #{opts.inspect}"
        end
        key = pkey.blank? ? selection_key : "#{pkey}_#{selection_key}"
        #warn "gvkey #{selection_key}, #{opts.inspect} R:#{key}"
        key.to_sym
      end

      def get_module mod
        module_name_parts = mod.split('::').map(&:to_sym)
        module_name_parts.inject Wagn::Set do |base, part|
          return if base.nil?
          key = "#{base}::#{part}"
          args = Cardlib::Patterns::BasePattern.ruby19 ? [part, false] : [part]
          Cardlib::Patterns::BasePattern::MODULES[key] ||= if base.const_defined?(*args)
                base.const_get *args
              else
                base.const_set part.to_sym, Module.new
              end
        end
      rescue NameError => e
        warn "rescue ne #{e.inspect}, #{e.backtrace*"\n"}"
        nil
      end

      def namespace spc, &block
        const = get_module spc
        #warn "namespace2: #{spc.inspect} :: #{const}"
        const.module_eval &block
      end
    end

    CARDLIB   = "#{Rails.root}/lib/cardlib/*.rb"
    SETS      = "#{Rails.root}/lib/wagn/set/"
    RENDERERS = "#{Rails.root}/lib/wagn/renderer/*.rb"

    class << self
      def load_cardlib  ; load_dir File.expand_path( CARDLIB, __FILE__   ) end
      def load_renderers; load_dir File.expand_path( RENDERERS, __FILE__ ) end
      def dir newdir    ; @@dirs << newdir                                 end
      def load_dirs     ; @@dirs.each { |dir| load_dir dir }               end

      def load_sets
        [ SETS, Wagn::Conf[:pack_dirs].split( /,\s*/ ) ].flatten.each do |dirname|
          load_dir File.expand_path( "#{dirname}/**/*.rb", __FILE__ )
        end
      end

      def load_dir dir
        Dir[dir].each do |file|
          begin
            require_dependency file
          rescue Exception=>e
            Rails.logger.warn "Error loading file #{file}: #{e.message}"
            Rails.logger.debug "Error loading file #{file}: #{e.message}\n#{e.backtrace*"\n"}"
            raise e
          end
        end
      end
    end

    # View definitions
    #
    #   When you declare:
    #     define_view :view_name, "<set>" do |args|
    #
    #   Methods are defined on the renderer
    #
    #   The external api with checks:
    #     render(:viewname, args)
    #
    #   Roughly equivalent to:
    #     render_viewname(args)
    #
    #   The internal call that skips the checks:
    #     _render_viewname(args)
    #
    #   Each of the above ultimately calls:
    #     _final(_set_key)_viewname(args)

    module ClassMethods

      include SharedMethods

      def format fmt=nil
        Renderer.renderer = if fmt.nil? || fmt == :base then Renderer else Renderer.get_renderer fmt end
      end

      def define_view view, opts={}, &final
        Renderer.perms[view]       = opts.delete(:perms)      if opts[:perms]
        Renderer.error_codes[view] = opts.delete(:error_code) if opts[:error_code]
        Renderer.denial_views[view]= opts.delete(:denial)     if opts[:denial]
        if opts[:tags]
          [opts[:tags]].flatten.each do |tag|
            Renderer.view_tags[view] ||= {}
            Renderer.view_tags[view][tag] = true
          end
        end

        view_key = get_set_key view, opts
        Renderer.renderer.class_eval { define_method "_final_#{view_key}", &final }
        #warn "defining view method[#{Renderer.renderer.inspect}] _final_#{view_key}"
        Renderer.subset_views[view] = true if !opts.empty?

        if !method_defined? "render_#{view}"
          #warn "defining view method[#{Renderer.renderer}] _render_#{view}"
          Renderer.renderer.class_eval do
            define_method( "_render_#{view}" ) do |*a|
              a = [{}] if a.empty?
              if final_method = view_method(view)
                with_inclusion_mode view do
                  send final_method, *a
                end
              else
                raise "<strong>unsupported view: <em>#{view}</em></strong>"
              end
            end
          end

          #Rails.logger.warn "define_method render_#{view}"
          Renderer.renderer.class_eval do
            define_method( "render_#{view}" ) do |*a|
              begin
                send( "_render_#{ ok_view view, *a }", *a )
              rescue Exception=>e
                controller.send :notify_airbrake, e if Airbrake.configuration.api_key
                warn "Render Error: #{e.class} : #{e.message}"
                Rails.logger.info "\nRender Error: #{e.class} : #{e.message}"
                Rails.logger.debug "  #{e.backtrace*"\n  "}"
                rendering_error e, (card && card.name.present? ? card.name : 'unknown card')
              end
            end
          end
        end
      end

      def alias_view view, opts={}, *aliases
        view_key = get_set_key view, opts
        Renderer.subset_views[view] = true if !opts.empty?
        aliases.each do |alias_view|
          alias_view_key = case alias_view
            when String; alias_view
            when Symbol; (view_key==view ? alias_view.to_sym : view_key.to_s.sub(/_#{view}$/, "_#{alias_view}").to_sym)
            when Hash;   get_set_key alias_view[:view] || view, alias_view
            else; raise "Bad view #{alias_view.inspect}"
            end

            #Rails.logger.warn "def view final_alias #{alias_view_key}, #{view_key}"
            Renderer.renderer.class_eval { define_method( "_final_#{alias_view_key}".to_sym ) do |*a|
            send "_final_#{view_key}", *a
          end }
        end
      end
    end

  end
end


