
require 'wagn/renderer'

module Wagn

  module Sets
    @@dirs = []
    class << self

      def load
        load_dir File.expand_path( "#{Rails.root}/lib/wagn/renderer/*.rb", __FILE__ )

        load_dir File.expand_path( "#{Rails.root}/lib/wagn/set/**/*.rb", __FILE__ )

        load_dir File.expand_path( "#{Rails.root}/lib/wagn/model/*.rb", __FILE__ )
      end

      def all_constants base
        base.constants.map {|c| c=base.const_get(c) and all_constants(c) }
      end


      def dir newdir
        @@dirs << newdir
      end

      def load_dir dir
        Dir[dir].each do |file|
          begin
            require_dependency file
          rescue Exception=>e
            Rails.logger.warn "Error loading file #{file}: #{e.message}\n#{e.backtrace*"\n"}"
            raise e
          end
        end
      end

      def load_dirs
        @@dirs.each do |dir| load_dir dir end
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

      def format fmt=nil
        return @@renderer = Renderer if fmt.nil? || fmt == :base
        renderer = Renderer.get_renderer fmt
        @@renderer = Renderer.const_defined?(renderer) ? Renderer.const_get(renderer) : raise("Bad format #{renderer}, #{fmt}")
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

        view_key = get_view_key(view, opts)
        @@renderer.class_eval { define_method "_final_#{view_key}", &final }
        #warn "defining method[#{@@renderer}] _final_#{view_key}"
        Renderer.subset_views[view] = true if !opts.empty?

        if !method_defined? "render_#{view}"
          #warn "defining method[#{@@renderer}] render_#{view}"
          @@renderer.class_eval do
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

          @@renderer.class_eval do
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
        view_key = get_view_key(view, opts)
        Renderer.subset_views[view] = true if !opts.empty?
        aliases.each do |aview|
          aview_key = case aview
            when String; aview
            when Symbol; (view_key==view ? aview.to_sym : view_key.to_s.sub(/_#{view}$/, "_#{aview}").to_sym)
            when Hash;   get_view_key( aview[:view] || view, aview)
            else; raise "Bad view #{aview.inspect}"
            end

          #warn "def final_alias #{aview_key}, #{view_key}"
          @@renderer.class_eval { define_method( "_final_#{aview_key}".to_sym ) do |*a|
            send("_final_#{view_key}", *a)
          end }
        end
      end

      private

      def get_view_key view, opts
        unless pkey = Wagn::Model::Pattern.method_key(opts)
          raise "bad method_key opts: #{pkey.inspect} #{opts.inspect}"
        end
        key = pkey.blank? ? view : "#{pkey}_#{view}"
        #warn "gvkey #{view}, #{opts.inspect} R:#{key}"
        key.to_sym
      end
    end

    module AllSets
      Wagn::Sets.all_constants(Wagn::Set)
    end

    def self.included base
      super
      base.extend ClassMethods
    end
  end
end


