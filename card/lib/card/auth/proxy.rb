class Card
  module Auth
    # mechanism for assuming permissions of another user.
    module Proxy
      # operate with the permissions of another "proxy" user
      def as given_user
        tmp_id   = @as_id
        tmp_card = @as_card

        @as_id   = get_user_id(given_user)
        @as_card = nil
        # we could go ahead and set as_card if given a card...

        @current_id = @as_id if @current_id.nil?

        return unless block_given?
        yield
      ensure
        if block_given?
          @as_id   = tmp_id
          @as_card = tmp_card
        end
      end

      # operate with the permissions of WagnBot (administrator)
      def as_bot &block
        as Card::WagnBotID, &block
      end

      # id of proxy user
      # @return [Integer]
      def as_id
        @as_id || current_id
      end

      # proxy user card
      # @return [Card]
      def as_card
        if @as_card && @as_card.id == as_id
          @as_card
        else
          @as_card = Card[as_id]
        end
      end

      # get card id from args of unknown type
      # @todo replace with general mechanism, eg #quick_fetch
      def get_user_id user
        case user
        when NilClass then nil
        when Card     then user.id
        when Fixnum   then user
        else Card.fetch_id(user)
        end
      end
    end
  end
end
