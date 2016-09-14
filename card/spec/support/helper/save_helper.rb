class Card
  module SpecHelper
    module SaveHelper
      include Card::Model::SaveHelper
      def create! name, content=""
        Card.create! name: name, content: content
      end

      def create_or_update name_or_args, args={}
        Card::Auth.as_bot { super }
      end

      def update name, args
        Card::Auth.as_bot { update_card name, args }
      end
    end
  end
end