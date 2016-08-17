# -*- encoding : utf-8 -*-

class Card
  # Singleton methods for authentication
  module Auth
    extend Card::Auth::Permissions
    extend Card::Auth::Proxy
    extend Card::Auth::Setup

    @as_card = @as_id = @current_id = @current = nil

    class << self
      def signin signin_id
        self.current_id = signin_id
        session[:user] = signin_id if session
      end

      def signed_in?
        current_id != Card::AnonymousID
      end

      def current_id
        @current_id ||= Card::AnonymousID
      end

      def current
        if @current && @current.id == current_id
          @current
        else
          @current = Card[current_id]
        end
      end

      def current_id= card_id
        @current = @as_id = @as_card = nil
        card_id = card_id.to_i if card_id.present?
        @current_id = card_id
      end

      def current= mark
        self.current_id =
          if mark.to_s =~ /@/
            account = Auth.find_account_by_email mark.downcase
            account && account.active? ? account.left_id : Card::AnonymousID
          else
            mark
          end
      end

      def session
        Card::Env[:session]
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

      # find +*account card by +*token card
      # @param token [String]
      # @return [+*account card, nil]
      def find_account_by_token token
        find_account_by "token", Card::TokenID, token.strip
      end

      # find +*account card by +*email card
      # @param email [String]
      # @return [+*account card, nil]
      def find_account_by_email email
        find_account_by "email", Card::EmailID, email.strip.downcase
      end

      # general pattern for finding +*account card based on field cards
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

      # authenticate a user by their login name and unencrypted password.
      # @param email [String]
      # @param password [String]
      # @return [+*account card, nil]
      def authenticate email, password
        account = Auth.find_account_by_email email
        case
        when !account                                 then nil
        when !account.active?                         then nil
        when Card.config.no_authentication            then account
        when password_valid?(account, password.strip) then account
        end
      end

      # check whether password is correct for account card
      # @param account [+*account card]
      # @param password [String]
      def password_valid? account, password
        account.password == encrypt(password, account.salt)
      end

      # encrypt password string with the given salt.
      # @return [SHA1 String]
      def encrypt password, salt
        Digest::SHA1.hexdigest "#{salt}--#{password}--"
      end
    end
  end
end
