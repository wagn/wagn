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

      cattr_accessor :rspec_binding

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

      def format_with_set set, format_type=:html
        singleton_class.send :include, set
        format = format format_type
        format_class = Card::Format.format_class_name format_type
        format.singleton_class.send :include, set.const_get(format_class)
        yield(format)
      end
    end
  end
end