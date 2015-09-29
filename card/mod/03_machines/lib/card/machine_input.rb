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
      host_class.extend( ClassMethods )
      host_class.machines_wql = {}
      host_class.machine_input do
        format._render_raw
      end

      event_suffix = host_class.name.gsub ':', '_'

      host_class.event(
        "after_machine_input_updated_#{ event_suffix }".to_sym,
        after: :extend, on: :save
      ) do

        wql_statement = { right_plus: [
          { codename: "machine_input" },
          { link_to: name}
        ]}.merge(host_class.machines_wql)
        machines = Card.search(wql_statement)
        machines.each do |item|
          item.reset_machine_output! if item.kind_of? Machine
        end
      end

      host_class.event(
        "before_machine_input_deleted_#{ event_suffix }".to_sym,
        after: :approve, on: :delete
      ) do

        @involved_machines = Card.search(
          {right_plus: [
            {codename: "machine_input"},
            {link_to: name}
          ]}.merge(host_class.machines_wql)
        )
      end

      host_class.event(
       "after_machine_input_deleted_#{ event_suffix }".to_sym,
       after: :store_subcards, on: :delete
      ) do

        @involved_machines.each do |item|
          item.reset_machine_output! if item.kind_of? Machine
        end
      end
    end
  end
end

