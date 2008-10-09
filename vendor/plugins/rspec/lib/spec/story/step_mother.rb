module Spec
  module Story
    class StepMother
      def initialize
        @steps = StepGroup.new
      end
      
      def use(new_step_group)
        @steps << new_step_group
      end
      
      def store(type, step)
        @steps.add(type, step)
      end
      
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/story/step_mother.rb
      def find(type, unstripped_name)
        name = unstripped_name.strip
=======
      def find(type, name)
>>>>>>> add/update rspec:vendor/plugins/rspec/lib/spec/story/step_mother.rb
        if @steps.find(type, name).nil?
          @steps.add(type,
          Step.new(name) do
            raise Spec::Example::ExamplePendingError.new("Unimplemented step: #{name}")
          end
          )
        end
        @steps.find(type, name)
      end
      
      def clear
        @steps.clear
      end
      
      def empty?
        @steps.empty?
      end
      
    end
  end
end
