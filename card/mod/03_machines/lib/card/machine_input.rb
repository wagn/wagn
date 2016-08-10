class Card
  module MachineInput
    module ClassMethods
      attr_accessor :machines_wql

      def machine_input_for args
        @machines_wql = args
      end

      def machine_input &block
        define_method :machine_input, block
      end
    end

    def self.included host_class
      host_class.extend(ClassMethods)
      host_class.machines_wql = {}
      host_class.machine_input do
        format._render_raw
      end
      event_suffix = host_class.name.tr ":", "_"
      define_update_event event_suffix, host_class
      define_delete_events event_suffix, host_class
    end

    def self.define_delete_events event_suffix, host_class
      event_name = "before_machine_input_deleted_#{event_suffix}".to_sym
      host_class.event event_name, :store, on: :delete do
        # exclude self because it's on the way to the trash
        # otherwise it will be created again with the reset_machine_output
        # call in the event below
        @involved_machines =
          Card::MachineInput.search_involved_machines(name, host_class)
                            .reject { |card| card == self }
      end
      event_name = "after_machine_input_deleted_#{event_suffix}".to_sym
      host_class.event event_name, :finalize, on: :delete do
        expire_machine_cache
        @involved_machines.each do |item|
          item.reset_machine_output if item.is_a? Machine
        end
      end
    end

    def self.define_update_event event_suffix, host_class
      host_class.event(
        "after_machine_input_updated_#{event_suffix}".to_sym, :integrate,
        on: :save
      ) do
        expire_machine_cache
        Card::MachineInput.search_involved_machines(name, host_class)
                          .each do |item|
          item.reset_machine_output if item.is_a? Machine
        end
      end
    end

    def self.search_involved_machines name, host_class
      wql_statement =
        { right_plus: [
          { codename: "machine_input" },
          { link_to: name }
        ] }.merge(host_class.machines_wql)
      Card.search(wql_statement)
    end

    def expire_machine_cache
      Card.search(right_plus: [
                    { codename: "machine_input" },
                    { link_to: name }
                  ],
                  return: :name).each do |machine_name|
        next unless (cache = Card.fetch(name, machine_name, :machine_cache))
        Auth.as_bot do
          cache.update_attributes! trash: true
        end
      end
    end
  end
end
