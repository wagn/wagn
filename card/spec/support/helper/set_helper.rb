class Card
  module SpecHelper
    # To be included in Card.
    # Defines helper to change card sets and formats
    module SetHelper
      # define dynamically views (or other things) on format objects
      # @return format object
      # @example add a view to a card's html format
      # format =
      #   Card["A"].attach_to_format(:html) do
      #     view :my_test_view do
      #       card.name
      #     end
      #   end
      # format.render :my_test_view  # => "A"
      def format_with format_type=:html, &block
        dynamic_set =
          create_dynamic_set do
            format(format_type, &block)
          end
        format_with_set dynamic_set, format_type
        #::Card::Set::Self::DynamicSet, :html
      end

      # define dynamically sets on card objects
      # @return card object
      def set_with &block
        with_set create_dynamic_set(&block)
      end

      # load set into card object
      def with_set set
        set = include_set_in_test_set(set) if set.abstract_set?
        singleton_class.send :include, set
        yield set if block_given?
        self
      end

      # load set into a card's format object
      def format_with_set set, format_type=:base
        format = format format_type
        with_set set do |extended_set|
          format_class = set_format_class(extended_set, format_type)
          format.singleton_class.send :include, format_class
        end
        block_given? ? yield(format) : format
      end

      def set_format_class set, format_type
        format_class = Card::Format.format_class_name format_type
        set.const_get format_class
      end

      def include_set_in_test_set set
        # rubocop:disable Lint/Eval
        ::Card::Set::Self.const_remove_if_defined :TestSet
        eval <<-RUBY
          class ::Card::Set::Self
            module TestSet
              extend Card::Set
              include_set #{set}
            end
          end
        RUBY
        ::Card::Set::Self::TestSet
        # rubocop:enable Lint/Eval
      end

      private

      def create_dynamic_set &block
        ::Card::Set::Self.const_remove_if_defined :DynamicSet
        ::Card::Set::Self.const_set :DynamicSet, Module.new
        ::Card::Set::Self::DynamicSet.extend Card::Set
        ::Card::Set::Self::DynamicSet.module_eval &block
        ::Card::Set::Self::DynamicSet
      end
    end
  end
end
