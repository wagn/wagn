module Spec
  module Rails
    module Example
      class AssignsHashProxy #:nodoc:
<<<<<<< HEAD:vendor/plugins/rspec-rails/lib/spec/rails/example/assigns_hash_proxy.rb
        def initialize(example_group, &block)
          @block = block
          @example_group = example_group
=======
        def initialize(object)
          @object = object
>>>>>>> add/update rspec:vendor/plugins/rspec-rails/lib/spec/rails/example/assigns_hash_proxy.rb
        end

        def [](ivar)
          if assigns.include?(ivar.to_s)
            assigns[ivar.to_s]
          elsif assigns.include?(ivar)
            assigns[ivar]
          else
            nil
          end
        end

        def []=(ivar, val)
<<<<<<< HEAD:vendor/plugins/rspec-rails/lib/spec/rails/example/assigns_hash_proxy.rb
          @block.call.instance_variable_set("@#{ivar}", val)
=======
          @object.instance_variable_set "@#{ivar}", val
          assigns[ivar.to_s] = val
>>>>>>> add/update rspec:vendor/plugins/rspec-rails/lib/spec/rails/example/assigns_hash_proxy.rb
        end

        def delete(name)
          assigns.delete(name.to_s)
        end

        def each(&block)
          assigns.each &block
        end

        def has_key?(key)
          assigns.key?(key.to_s)
        end

        protected
        def assigns
<<<<<<< HEAD:vendor/plugins/rspec-rails/lib/spec/rails/example/assigns_hash_proxy.rb
          @example_group.orig_assigns
=======
          @object.assigns
>>>>>>> add/update rspec:vendor/plugins/rspec-rails/lib/spec/rails/example/assigns_hash_proxy.rb
        end
      end
    end
  end
end
