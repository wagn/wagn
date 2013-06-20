# -*- encoding : utf-8 -*-

class Card
  
  def self.register_pattern klass, index=nil
    self.set_patterns = [] unless set_patterns
    set_patterns.insert index.to_i, klass
  end

  module Set
    mattr_accessor :current_set_opts, :current_set_module
    # View definitions
    #
    #   When you declare:
    #     view :view_name, "<set>" do |args|
    #
    #   Methods are defined on the format
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


    def format fmt=nil, &block
      if block_given?
        f = Card::Format
        format = fmt.nil? ? f : f.get_format(fmt)
        format.class_eval &block
      else
        fail "block required"
      end
    end
    
    def view *args, &block
      format do view *args, &block end
    end
    
    def event event, opts={}, &final

      opts[:on] = [:create, :update ] if opts[:on] == :save

      Card.define_callbacks event

      mod = self.ancestors.first
      mod_name = mod.name || Card::Set.current_set_module
      mod = if mod == Card || mod_name =~ /^Card::Set::All::/
          Card
        else
          Card.find_set_model_module( mod_name ) || mod
        end

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

            parts = mod_name.split '::'
            set_class_key = parts[-2].underscore
            anchor_or_placeholder = parts[-1].underscore
            set_key = Card.method_key( { set_class_key.to_sym => anchor_or_placeholder } )

            if set_key.present?
              Card.class_eval do
                set_callback object_method, kind, event, :prepend=>true, :if => proc { |c| c.method_keys.include? set_key }
              end
            else
              Rails.logger.info( "EVENT defined for unknown set in #{mod_name}" )
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

  end
end

