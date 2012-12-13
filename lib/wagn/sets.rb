
require 'wagn/renderer'
require 'card_controller'

module Wagn

  module Sets
    @@dirs = []
    class << self

      def load
        load_dir File.expand_path( "#{Rails.root}/lib/wagn/renderer/*.rb", __FILE__ )
#        [ :renderer, :model ].each do |dirname|
#          load_dir( File.expand_path "#{Rails.root}/lib/wagn/#{dirname}/*.rb", __FILE__ )
#        end
        [ "#{Rails.root}/lib/wagn/set/", Wagn::Conf[:pack_dirs].split( /,\s*/ ) ].flatten.each do |dirname|
          load_dir File.expand_path( "#{dirname}/**/*.rb", __FILE__ )
        end
        
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

        view_key = get_set_key(view, opts)
        @@renderer.class_eval { define_method "_final_#{view_key}", &final }
        warn "defining view method[#{@@renderer}] _final_#{view_key}"
        Renderer.subset_views[view] = true if !opts.empty?

        if !method_defined? "render_#{view}"
          warn "defining view method[#{@@renderer}] render_#{view}"
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
        view_key = get_set_key(view, opts)
        Renderer.subset_views[view] = true if !opts.empty?
        aliases.each do |alias_view|
          alias_view_key = case alias_view
            when String; alias_view
            when Symbol; view_key==view ? alias_view.to_sym : view_key.to_s.sub(/_#{view}$/, "_#{alias_view}").to_sym
            when Hash;   get_set_key alias_view[:view] || view, alias_view
            else; raise "Bad view #{alias_view.inspect}"
            end

          warn "def view final_alias #{alias_view_key}, #{view_key}"
          @@renderer.class_eval { define_method( "_final_#{alias_view_key}".to_sym ) do |*a|
            send "_final_#{view_key}", *a
          end }
        end
      end

      # FIXME: the definition stuff is pretty much exactly parallel, DRY, fold them together

      def action event, opts={}, &final_action
        action_key = get_set_key event, opts
        #warn "define action #{event.inspect}, #{action_key}, O:#{opts.inspect}"

        CardController.class_eval { define_method "_final_#{action_key}", &final_action }

        CardController.subset_actions[event] = true if !opts.empty?

        if !method_defined? "process_#{event}"
          #warn "defining method: process_#{event}"
          CardController.class_eval do

            define_method( "_process_#{event}" ) do |*a|
              a = [{}] if a.empty?
              if final_method = action_method(event)
                #warn "final action #{final_method}"
                #with_inclusion_mode event do
                  send final_method, *a
                #end
              else
                raise "<strong>unsupported event: <em>#{event}</em></strong>"
              end
            end
          end

          CardController.class_eval do

            warn "define action process_#{event}"
            define_method( "process_#{event}" ) do |*a|
              begin

                warn "send _process_#{event}"
                send "_process_#{event}", *a

              rescue Exception=>e
                controller.send :notify_airbrake, e if Airbrake.configuration.api_key
                warn "Card Action Error: #{e.class} : #{e.message}"
                Rails.logger.info "\nCard Action Error: #{e.class} : #{e.message}"
                Rails.logger.debug "  #{e.backtrace*"\n  "}"
                rendering_error e, (card && card.name.present? ? card.name : 'unknown card')
              end
            end
          end
        end
      end

      def alias_action event, opts={}, *aliases
        event_key = get_set_key(event, opts)
        Renderer.subset_actions[event] = true if !opts.empty?
        aliases.each do |alias_event|
          alias_event_key = case alias_event
            when String; alias_event
            when Symbol; event_key==event ? alias_event.to_sym : event_key.to_s.sub(/_#{event}$/, "_#{alias_event}").to_sym
            when Hash;   get_set_key alias_event[:event] || event, alias_event
            else; raise "Bad event #{alias_event.inspect}"
            end

          warn "def final_alias action #{alias_event_key}, #{event_key}"
          @@renderer.class_eval { define_method( "_final_#{alias_event_key}".to_sym ) do |*a|
            send "_final_#{event_key}", *a
          end }
        end
      end

    end


    module SharedClassMethods

      private

      def get_set_key selection_key, opts
        unless pkey = Wagn::Model::Pattern.method_key(opts)
          raise "bad method_key opts: #{pkey.inspect} #{opts.inspect}"
        end
        key = pkey.blank? ? selection_key : "#{pkey}_#{selection_key}"
        #warn "gvkey #{selection_key}, #{opts.inspect} p:#{pkey} R:#{key}"
        key.to_sym
      end
    end

    module AllSets
      Wagn::Sets.all_constants(Wagn::Set)
    end

    def self.included base
      super
      CardController.extend SharedClassMethods
      base.extend SharedClassMethods
      base.extend ClassMethods
    end
  end
end


