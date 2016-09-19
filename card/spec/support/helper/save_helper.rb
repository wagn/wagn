class Card
  module SpecHelper
    module SaveHelper
      include Card::Model::SaveHelper
      def create! name, content=""
        Card.create! name: name, content: content
      end

      def create name_or_args, content_or_args=nil
        Card::Auth.as_bot { super }
      end

      def create_or_update name_or_args, content_or_args=nil
        Card::Auth.as_bot { super }
      end

      def update name_or_args, content_or_args=nil
        Card::Auth.as_bot { super }
      end

      def delete name
        Card::Auth.as_bot { Card[name].delete! }
      end
    end
  end
end
