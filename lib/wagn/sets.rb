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

=begin
      def get_module mod
        module_name_parts = mod.split('::').map(&:to_sym)
        module_name_parts.inject Wagn::Set do |base, part|
          return if base.nil?
          key = "#{base}::#{part}"
          args = Cardlib::Patterns::BasePattern::RUBY19 ? [part, false] : [part]
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
=end
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

    # this module also get the action definitions
    module CardActions
      @@subset_actions = {}

      mattr_reader :subset_actions
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
        #warn "defining view method[#{Renderer.current_class}] _final_#{view_key}"
        Renderer.current_class.class_eval { define_method "_final_#{view_key}", &final }
        Renderer.subset_views[view] = true if !opts.empty?

        if !method_defined? "render_#{view}"
          #warn "defining view method[#{Renderer.current_class}] _render_#{view}"
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


      #
      # ~~~~~~~~~~~~~~~~~~  ACTION DEFINITION ~~~~~~~~~~~~~~~~~~~
      #

      DEFAULT_ALIAS = {
        :perform_create    => :create,
        :perform_read      => :read,
        :perform_update    => :update,
        :perform_delete    => :delete,
        :perform_index     => :read,
        :perform_read_file => :read_file,
      }

      def action event, opts={}, &final_action
        action_key = get_set_key event, opts

        CardActions.class_eval {
        Rails.logger.warn "define action[#{self}] e:#{event.inspect}, ak:_final_#{action_key}, O:#{opts.inspect}" if event == :read
          define_method "_final_#{action_key}", &final_action }

        CardActions.subset_actions[event] = true if !opts.empty?

        if !method_defined?( core_method = "perform_#{event}".to_sym )
          ucore_method = "_#{core_method}".to_sym
          CardActions.class_eval do

            Rails.logger.warn "defining method[#{to_s}] #{ucore_method}" if event == :read
            define_method( ucore_method ) do |*a|
              a = [{}] if a.empty?
              if final_method = action_method(event)
                Rails.logger.warn "final action #{final_method}"
                #with_inclusion_mode event do
                  send final_method, *a
                #end
              else
                raise "<strong>unsupported event: <em>#{event}</em></strong>"
              end
            end

            Rails.logger.warn "define action[#{self}] #{core_method}" if event == :read
            define_method( core_method ) do |*a|
              begin

                send "_#{core_method}", *a

              rescue Exception=>e
                controller.send :notify_airbrake, e if Airbrake.configuration.api_key
                Rails.logger.info "\nCard Action Error[#{core_method} #{e.class} : #{e.message}"
                Rails.logger.debug "  #{e.backtrace*"\n  "}"
                action_error e, (card && card.name.present? ? card.name : 'unknown card')
              end
            end

            default_alias = DEFAULT_ALIAS[ core_method ] and
                alias_method default_alias, core_method
          end
        end
      end

      def alias_action event, opts={}, *aliases
        event_key = get_set_key(event, opts)
        CardActions.subset_actions[event] = true if !opts.empty?
        aliases.each do |alias_event|
          alias_event_key = case alias_event
            when String; alias_event
            when Symbol; event_key==event ? alias_event.to_sym : event_key.to_s.sub(/_#{event}$/, "_#{alias_event}").to_sym
            when Hash;   get_set_key alias_event[:event] || event, alias_event
            else; raise "Bad event #{alias_event.inspect}"
            end

          Rails.logger.warn "def final_alias action #{alias_event_key}, #{event_key}"
          CardActions.class_eval { define_method( "_final_#{alias_event_key}".to_sym ) do |*a|
            send "_final_#{event_key}", *a
          end }
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


