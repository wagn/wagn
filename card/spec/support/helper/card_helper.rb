class Card
  module SpecHelper
    # to be included in Card
    module CardHelper
      module ClassMethods
        def gimme! name, args={}
          Card::Auth.as_bot do
            c = Card.fetch(name, new: args)
            c.putty args
            Card.fetch name
          end
        end

        def gimme name, args={}
          Card::Auth.as_bot do
            c = Card.fetch(name, new: args)
            if args[:content] && c.content != args[:content]
              c.putty args
              c = Card.fetch name
            end
            c
          end
        end

        cattr_accessor :rspec_binding
      end

      def putty args={}
        Card::Auth.as_bot do
          if args.present?
            update_attributes! args
          else
            save!
          end
        end
      end

      # rubocop:disable Lint/Eval
      def method_missing m, *args, &block
        return super unless Card.rspec_binding
        suppress_name_error do
          method = eval("method(%s)" % m.inspect, Card.rspec_binding)
          return method.call(*args, &block)
        end
        suppress_name_error do
          return eval(m.to_s, Card.rspec_binding)
        end
        super
      end
      # rubocop:enable Lint/Eval

      def suppress_name_error
        yield
      rescue NameError
      end
    end
  end
end
