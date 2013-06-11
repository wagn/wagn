# -*- encoding : utf-8 -*-

module Wagn
  module Set
    mattr_accessor :current_set_opts
    # View definitions
    #
    #   When you declare:
    #     view :view_name, "<set>" do |args|
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

    #
    # ~~~~~~~~~~  VIEW DEFINITION
    #

    def view view, *args, &final
      

    
      
      if block_given?
        define_view view, (args[0] || {}), &final
      else
        opts = Hash===args[0] ? args.shift : nil
        alias_view view, opts, args.shift
      end
    end
    
    def define_view view, opts, &final
      Renderer.perms[view]       = opts.delete(:perms)      if opts[:perms]
      Renderer.error_codes[view] = opts.delete(:error_code) if opts[:error_code]
      Renderer.denial_views[view]= opts.delete(:denial)     if opts[:denial]
      
      if opts[:tags]
        [opts[:tags]].flatten.each do |tag|
          Renderer.view_tags[view] ||= {}
          Renderer.view_tags[view][tag] = true
        end
      end
      
      if set_opts = Wagn::Set.current_set_opts
        opts.merge! set_opts
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
    
    def alias_view alias_view, opts, referent_view=nil
      
      Renderer.subset_views[alias_view] = true if opts && !opts.empty?
      
      referent_view ||= alias_view
      alias_opts = Wagn::Set.current_set_opts || {}
      referent_view_key = get_set_key referent_view, (opts || alias_opts)
      alias_view_key = get_set_key alias_view, alias_opts
      
      #warn "alias = #{alias_view_key}, referent = #{referent_view_key}"
    
      #Rails.logger.info( warn "def view final_alias #{alias_view_key}, #{view_key}" )
      Renderer.current_class.class_eval do
        define_method "_final_#{alias_view_key}".to_sym do |*a|
          send "_final_#{referent_view_key}", *a
        end
      end
    end



    def format fmt=nil
      if block_given?
        format fmt
        yield
        format :base
      else
        Renderer.current_class = if fmt.nil? || fmt == :base
          Renderer
        else
          Renderer.get_renderer fmt
        end
      end
    end



    def event event, opts={}, &final

      opts[:on] = [:create, :update ] if opts[:on] == :save

      mod = self.ancestors.first
      mod = case
        when mod == Card                          ; Card
        when mod.name =~ /^Cardlib/               ; Card
        when mod.name =~ /^Wagn::Set::All::/      ; Card
        when modl = Card.find_set_model_module( mod.name )  ; modl
        else mod.const_set :Model, Module.new
        end

      Card.define_callbacks event

      mod.class_eval do
        include ActiveSupport::Callbacks

        final_method = "#{event}_without_callbacks" #should be private?
        define_method final_method, &final

        define_method event do #|*a, &block|
          #warn "running #{event} for #{name}"
          run_callbacks event do
            action = self.instance_variable_get(:@action)
            if !opts[:on] or Array.wrap(opts[:on]).member? action
              send final_method #, :block=>block
            end
          end
        end
      end


      [:before, :after, :around].each do |kind|

        if object_method = opts[kind]
          if mod == Card
            Card.class_eval { set_callback object_method, kind, event, :prepend=>true }
          else

            # Here is the current handling for non-all sets.  All callbacks are added directly to card and the set fitness is checked directly.
            # My original intent was to add the callbacks to the singleton class (see code below).  We may have to go back to that approach if we
            # encounter problems with ordering, overrides, etc with this.

            parts = mod.name.split '::'
            set_class_key = parts[-3].underscore
            anchor_or_placeholder = parts[-2].underscore
            set_key = Card.method_key( { set_class_key.to_sym => anchor_or_placeholder } )

            if set_key.present?
              Card.class_eval do
                set_callback object_method, kind, event, :prepend=>true, :if => proc { |c| c.method_keys.include? set_key }
              end
            else
              puts Rails.logger.info( "EVENT defined for unknown set in #{mod.name}" )
            end
          end
        end
      end
    end

    # first attempt at non-all sets was to have the callbacks added to the singleton classes.  They were preprocessed as follows....

    #            if mod == Card
    #              mod.class_eval do
    #                set_callback object_method, kind, event, :prepend=>true
    #              end
    #            else
    #              mod.class_eval do
    #                unless class_variable_defined?(:@@callbacks)
    #                  mattr_accessor :callbacks
    #                  self.callbacks = []
    #                end
    #                self.callbacks << [ object_method, kind, event ]
    #              end
    #            end

    # ... and then handled in #include_set_modules like so:
    #
    #   singleton_class.send :include, m

    #    if m.respond_to? :callbacks
    #      m.callbacks.each do |object_method, kind, event|
    #        singleton_class.set_callback object_method, kind, event, :prepend=>true
    #      end
    #    end

    #  it may have been more appropriate to add the callbacks elsewhere, but point is current moot, as the callback definitions were screwing with the Card class.
    #  I may have been doing something wrong, but it seemed like the callback class attributes were handling things fine, but the runner methods were getting
    #  inappropriately update on the Card class itself.  This wasn't super easy to debug, and the current solution occurred to me in the process, but I wanted to
    #  document the alternative here in case we decide that's ultimately cleaner and more appropriate.



    private

    # the following is poorly named; the "selection_key" (really means view_key, no?) has nothing to do with the set
    def get_set_key selection_key, opts
      unless pkey = Card.method_key(opts)
        raise "bad method_key opts: #{pkey.inspect} #{opts.inspect}"
      end
      key = pkey.blank? ? selection_key : "#{pkey}_#{selection_key}"
      #warn "gvkey #{selection_key}, #{opts.inspect} R:#{key}"
      key.to_sym
    end

  end
end

