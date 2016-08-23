# -*- encoding : utf-8 -*-
require_dependency "card/auth/permissions"
require_dependency "card/auth/proxy"
require_dependency "card/auth/setup"

class Card
  # Singleton methods for authentication. Manages current user,
  # "as" user, and password verification.
  module Auth
    extend Permissions
    extend Proxy
    extend Setup
    extend Current

    @as_card = @as_id = @current_id = @current = nil

    class << self
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
