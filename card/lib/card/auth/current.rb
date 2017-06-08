class Card
  module Auth
    # methods for setting current account
    module Current
      # set current user in process and session
      def signin signin_id
        self.current_id = signin_id
        session[:user] = signin_id if session
      end

      # current user is not anonymous
      # @return [true/false]
      def signed_in?
        current_id != Card::AnonymousID
      end

      # id of current user card.
      # @return [Integer]
      def current_id
        @current_id ||= Card::AnonymousID
      end

      # current accounted card (must have +\*account)
      # @return [Card]
      def current
        if @current && @current.id == current_id
          @current
        else
          @current = Card[current_id]
        end
      end

      # set the id of the current user.
      def current_id= card_id
        @current = @as_id = @as_card = nil
        card_id = card_id.to_i if card_id.present?
        @current_id = card_id
      end

      # set current user from email or id
      # @return [Integer]
      def current= mark
        self.current_id =
          if mark.to_s =~ /@/
            account = Auth.find_account_by_email mark
            account && account.active? ? account.left_id : Card::AnonymousID
          else
            mark
          end
      end

      def serialize
        { as_id: as_id, current_id: current_id }
      end

      # @param auth_data [Integer|Hash] user id or a hash
      # @opts auth_data [Integer] current_id
      # @opts auth_data [Integer] as_id
      def with auth_data
        auth_data = { current_id: auth_data } if auth_data.is_a?(Integer)
        raise ArgumentError unless auth_data.is_a? Hash

        tmp_current = current_id
        tmp_as_id = as_id
        @current_id = auth_data[:current_id]
        @as_id = auth_data[:as_id] if auth_data[:as_id]
        yield
      ensure
        @current_id = tmp_current
        @as_id = tmp_as_id
      end

      # get session object from Env
      # return [Session]
      def session
        Card::Env[:session]
      end

      # set current from token or session
      def set_current token, current
        if token
          ok = set_current_from_token token, current
          raise Card::Error::Oops, "token authentication failed" unless ok
          # arguably should be PermissionDenied; that requires a card object,
          # and that's not loaded yet.
        else
          set_current_from_session
        end
      end

      # get :user id from session and set Auth.current_id
      def set_current_from_session
        self.current_id =
          if session
            if (card_id = session[:user]) && Card.exists?(card_id)
              card_id
            else
              session[:user] = nil
            end
          end
        current_id
      end

      # set the current user based on token
      def set_current_from_token token, current=nil
        account = find_account_by_token token
        if account && account.validate_token!(token)
          unless current && always_ok_usr_id?(account.left_id)
            # can override current only if admin
            current = account.left_id
          end
          self.current = current
        elsif Env.params[:live_token]
          true
          # Used for activations and resets.
          # Continue as anonymous and address problem later
        else
          false
        end
      end

      # find +\*account card by +\*token card
      # @param token [String]
      # @return [+*account card, nil]
      def find_account_by_token token
        find_account_by "token", Card::TokenID, token.strip
      end

      # find +\*account card by +\*email card
      # @param email [String]
      # @return [+*account card, nil]
      def find_account_by_email email
        find_account_by "email", Card::EmailID, email.strip.downcase
      end

      # general pattern for finding +\*account card based on field cards
      # @param fieldname [String] right name of field card (for WQL comment)
      # @param field_id [Integer] card id of field's simple card
      # @param value [String] content of field
      # @return [+*account card, nil]
      def find_account_by fieldname, field_id, value
        Auth.as_bot do
          Card.search({ right_id: Card::AccountID,
                        right_plus: [{ id: field_id },
                                     { content: value }] },
                      "find +*account for #{fieldname} (#{value})").first
        end
      end
    end
  end
end
