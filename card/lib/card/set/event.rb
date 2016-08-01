class Card
  def deserialize_for_active_job! attr, env, current_id
    attr.each do |attname, args|
      # symbols are not allowed so all symbols arrive here as strings
      # convert strings that were symbols before back to symbols
      value = args[:symbol] ? args[:value].to_sym : args[:value]
      instance_variable_set("@#{attname}", value)
    end
    include_set_modules
    # If active jobs (and hence the integrate_with_delay events) don't run
    # in a background process then Card::Env.deserialize! decouples the
    # controller's params hash and the Card::Env's params hash with the
    # effect that params changes in the CardController get lost
    # (a crucial example are success params that are processed in
    # CardController#update_params_for_success)
    return if Wagn.config.active_job.queue_adapter == :inline
    Card::Env.deserialize! env
    Card::Auth.current_id = current_id
  end

  def serialize_for_active_job
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
  end

  def log_event_call event
    Rails.logger.debug "#{name}: #{event}"
    # puts "#{Card::DirectorRegister.to_s}".green
  end


  module Set
    # Implements the event API for card sets
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

      private

      def define_event event, opts, &final
        final_method_name = "#{event}_without_callbacks" # should be private?
        class_eval do
          define_method final_method_name, &final
        end

        if with_delay? opts
          delaying_method = "#{event}_with_delay"
          define_event_delaying_method event, delaying_method
          define_event_method event, delaying_method
          define_active_job event, final_method_name, opts[:queue_as]
        else
          define_event_method event, final_method_name
        end
      end

      def with_delay? opts
        opts[:after] == :integrate_with_delay_stage ||
          opts[:before] == :integrate_with_delay_stage
      end

      def process_stage_opts opts
        if opts[:after] || opts[:before]
          # ignore :in options
        elsif opts[:in]
          opts[:after] = :"#{opts.delete(:in)}_stage" if opts[:in]
        end
        opts[:on] = [:create, :update] if opts[:on] == :save
      end

      def define_event_delaying_method event, method_name
        class_eval do
          define_method(method_name, proc do
            Object.const_get(event.to_s.camelize).perform_later(
              self, serialize_for_active_job, Card::Env.serialize,
              Card::Auth.current_id
            )
          end)
        end
      end

      def define_event_method event, call_method
        class_eval do
          define_method event do
            log_event_call event
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
      # @option queue [Symbol] (:default) the name of the queue
      def define_active_job name, final_method, queue=:integrate_with_delay
        class_name = name.to_s.camelize
        define_active_job_class class_name, queue || :integrate_with_delay
        define_active_job_perform_method class_name, final_method
      end

      def define_active_job_class class_name, queue
        eval %(
          class ::#{class_name} < ActiveJob::Base
            queue_as :#{queue}
          end
        )
      end

      def define_active_job_perform_method class_name, method_name
        Object.const_get(class_name).class_eval do
          define_method(
            :perform,
            proc do |card, card_attribs, env, current_id|
              card.deserialize_for_active_job! card_attribs, env, current_id
              card.send method_name
            end
          )
        end
      end

      def set_event_callbacks event, opts
        opts[:set] ||= self
        [:before, :after, :around].each do |kind|
          next unless (object_method = opts.delete(kind))
          Card.class_eval do
            set_callback(
              object_method, kind, event,
              prepend: true, if: proc { |c| c.event_applies?(opts) }
            )
          end
        end
      end
    end
  end
end
