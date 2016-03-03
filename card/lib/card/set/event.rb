class Card
  module Set
    module Event
      def event event, stage_or_opts={}, opts={}, &final
        if stage_or_opts.is_a? Symbol
          opts[:in] = stage_or_opts
        else
          opts = stage_or_opts
        end
        process_stage_opts opts

        Card.define_callbacks event
        define_event event, opts, &final
        set_event_callbacks event, opts
      end

      def define_event event, opts, &final
        final_method_name = "#{event}_without_callbacks" # should be private?
        class_eval do
          define_method final_method_name, &final
        end

        if with_delay? opts
          delaying_method = "#{event}_with_delay"
          define_event_delaying_method event, delaying_method
          define_event_method event, delaying_method, opts
          define_active_job event, final_method_name, opts[:queue_as]
        else
          define_event_method event, final_method_name, opts
        end
      end

      private

      def with_delay? opts
        opts[:after] == :integrate_with_delay_stage
      end

      def process_stage_opts opts
        case
        when opts[:after] || opts[:before]
          # ignore :in options
        when opts[:in]
          opts[:after] = :"#{opts.delete(:in)}_stage" if opts[:in]
        end
        opts[:on] = [:create, :update] if opts[:on] == :save
      end

      def define_event_delaying_method event, method_name
        class_eval do
          define_method method_name, proc {
            s_attr =
              serializable_attributes.each_with_object({}) do |name, hash|
                value = instance_variable_get("@#{name}")
                hash[name] =
                  # ActiveJob doesn't accept symbols as arguments
                  if value.is_a? Symbol
                    { value: value.to_s, symbol: true }
                  else
                    { value: value }
                  end
              end
            Object.const_get(event.to_s.camelize).perform_later(self, s_attr)
          }
        end
      end

      def define_event_method event, call_method, _opts
        class_eval do
          define_method event do
            # puts "#{name}:#{event}".red
            # puts "#{Card::DirectorRegister.to_s}".green
            run_callbacks event do
              send call_method
            end
          end
        end
      end

      # creates an Active Job.
      # The scheduled job gets the card object as argument and all serializable
      # attributes of the card.
      # (when the job is executed ActiveJob fetches the card from the database
      # so all attributes get lost)
      # @param name [String] the name for the ActiveJob child class
      # @param final_method [String] the name of the card instance method to be
      # queued
      # @option queue [Symbol] (:default) the name of the queue8
      def define_active_job name, final_method, queue=:default
        class_name = name.to_s.camelize
        eval %(
          class ::#{class_name} < ActiveJob::Base
            queue_as #{queue}
          end
        )
        Object.const_get(class_name).class_eval do
          define_method :perform, proc { |card, attributes|
            attributes.each do |attname, args|
              # symbols are not allowed so all symbols arrive here as strings
              # convert strings that were symbols before back to symbols
              value = args[:symbol] ? args[:value].to_sym : args[:value]
              card.instance_variable_set("@#{attname}", value)
            end
            card.include_set_modules
            card.send final_method
          }
        end
      end

      def set_event_callbacks event, opts
        [:before, :after, :around].each do |kind|
          next unless (object_method = opts.delete(kind))
          this_set_module = self
          Card.class_eval do
            set_callback(
              object_method, kind, event,
              prepend: true, if: proc do |c|
                c.singleton_class.include?(this_set_module) &&
                  c.event_applies?(opts)
              end
            )
          end
        end
      end
    end
  end
end
