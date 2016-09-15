class Card
  module SpecHelper
    module EventHelper
      # Make expectations in the event phase.
      # Takes a stage and registers the event_block in this stage as an event.
      # Unknown methods in the event_block are executed in the rspec context
      # instead of the card's context.
      # An additionally :trigger block in opts is expected that is called
      # to start the event phase.
      # Other event options like :on or :when are not supported yet.
      # Example:
      # in_stage :initialize,
      #          trigger: ->{ test_card.update_attributes! content: '' } do
      #            expect(item_names).to eq []
      #          end
      def in_stage stage, opts={}, &event_block
        Card.rspec_binding = binding
        add_test_event stage, :in_stage_test, opts, &event_block
        trigger =
          if opts[:trigger].is_a?(Symbol)
            method(opts[:trigger])
          else
            opts[:trigger]
          end
        trigger.call
      ensure
        remove_test_event stage, :in_stage_test
      end

      def add_test_event stage, name, opts={}, &event_block
        # use random set module that is always included so that the
        # event applies to all cards
        opts[:set] ||= Card::Set::All::Event
        if (only_for_card = opts.delete(:for))
          opts[:when] = proc { |c| c.name == only_for_card }
        end
        Card.class_eval do
          extend Card::Set::Event
          event name, stage, opts, &event_block
        end
      end

      def remove_test_event stage, name
        stage_sym = :"#{stage}_stage"
        Card.skip_callback stage_sym, :after, name
      end

      def test_event stage, opts={}, &block
        event_name = :"test_event_#{@events.size}"
        @events << [stage, event_name]
        add_test_event stage, event_name, opts, &block
      end

      def with_test_events
        @events = []
        Card.rspec_binding = binding
        yield
      ensure
        @events.each do |stage, name|
          remove_test_event stage, name
        end
        Card.rspec_binding = false
      end
    end
  end
end
