# -*- encoding : utf-8 -*-

module Wagn
  # pre-declare the root of the Modules namespace tree
  module Set
  end

  module Sets
    @@dirs = []

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
    end

    CARDLIB   = "#{Rails.root}/lib/cardlib/*.rb"
    SETS      = "#{Rails.root}/lib/wagn/set/"
    RENDERERS = "#{Rails.root}/lib/wagn/renderer/*.rb"

    class << self
      def load_cardlib  ; load_dir File.expand_path( CARDLIB, __FILE__   ) end
      def load_renderers; load_dir File.expand_path( RENDERERS, __FILE__ ) end
      #def dir newdir    ; @@dirs << newdir                                 end
      #def load_dirs     ; @@dirs.each { |dir| load_dir dir }               end

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

      #
      # ~~~~~~~~~~  VIEW DEFINITION
      #

      def format fmt=nil
        Renderer.current_class = if fmt.nil? || fmt == :base then Renderer else Renderer.get_renderer fmt end
      end


      def event event, opts={}, &final
        
        mod = self.ancestors.first
        mod = case 
          when mod == Card                          ; Card
          when mod.name =~ /^Wagn::Set::All::/      ; Card 
          when modl = Card.find_module( mod.name )  ; modl
          else
          end
            
        #puts "#{mod} -> #{event} (#{opts})"

        # I tried to do this without defining the final methods using Proc, lambda, etc, but couldn't quite get it to work.
        # perhaps final method should be private?
                
        mod.class_eval do
          include ActiveSupport::Callbacks
          define_callbacks event
          final_method = "_final_#{event}"
          define_method final_method, &final
          define_method event do #|*a, &block|
            run_callbacks event do
              action = self.instance_variable_get(:@action)
              if !opts[:action] or Array.wrap(opts[:action]).member? action
              #puts "#{final_method}"#{}" #{block}"
                send final_method #, :block=>block
              end
            end
          end

          [:before, :after, :around].each do |kind|
            if object_method = opts[kind]
              set_callback object_method, kind, event, :prepend=>true
            end
          end
        end
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
        #warn "defining view method[#{Renderer.renderer}] _final_#{view_key}"
        Renderer.current_class.class_eval { define_method "_final_#{view_key}", &final }
        Renderer.subset_views[view] = true if !opts.empty?

        if !method_defined? "render_#{view}"
          #warn "defining view method[#{Renderer.renderer}] _render_#{view}"
          Renderer.current_class.class_eval do
            define_method "_render_#{view}" do |*a|
              begin
                a = [{}] if a.empty?
                if final_method = view_method(view)
                  with_inclusion_mode view do
                    #Rails.logger.info( warn "rendering final method: #{final_method}" )
                    send final_method, *a
                  end
                else
                  unsupported_view view
                end
              rescue Exception=>e
                rescue_view e, view
              end
            end
          end

          #Rails.logger.warn "define_method render_#{view}"
          Renderer.current_class.class_eval do
            define_method "render_#{view}" do |*a|
              send "_render_#{ ok_view view, *a }", *a
            end
          end
        end
      end
      


      def alias_view view, opts={}, *aliases
        view_key = get_set_key view, opts
        Renderer.subset_views[view] = true if !opts.empty?
        aliases.each do |alias_view|
          alias_view_key = case alias_view
            when String
              alias_view
            when Symbol
              if view_key==view
                alias_view.to_sym
              else
                view_key.to_s.sub( /_#{view}$/, "_#{alias_view}" ).to_sym
              end
            when Hash
              get_set_key (alias_view[:view] || view), alias_view
            else
              raise "Bad view #{alias_view.inspect}"
            end

          #Rails.logger.info( warn "def view final_alias #{alias_view_key}, #{view_key}" )
          Renderer.current_class.class_eval do
            define_method "_final_#{alias_view_key}".to_sym do |*a|
              send "_final_#{view_key}", *a
            end
          end
        end
      end
    end

    def self.included base

      base.extend SharedMethods
      base.extend ClassMethods

      super

    end

  end
end


