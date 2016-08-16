# -*- encoding : utf-8 -*-

class Card
  module Auth
    @@as_card = @@as_id = @@current_id = @@current = nil
    @@simulating_setup_need = nil

    SETUP_COMPLETED_KEY = "SETUP_COMPLETED".freeze
    DEFAULT_RECAPTCHA_SETTINGS = {
      recaptcha_public_key: "6LeoHfESAAAAAN1NdQeYHREq4jTSQhu1foEzv6KC",
      recaptcha_private_key: "6LeoHfESAAAAAHLZpn7ijrO4_KGLEr2nGL4qjjis"
    }.freeze

    # after_save :reset_instance_cache

    class << self
      # Authenticates a user by their login name and unencrypted password.
      def authenticate email, password
        account = Auth[email]
        case
        when !account                                 then nil
        when !account.active?                         then nil
        when Card.config.no_authentication            then account
        when password_valid?(account, password.strip) then account
        end
      end

      def password_valid? account, password
        account.password == encrypt(password, account.salt)
      end

      def set_current_from_token token, current=nil
        account = find_by_token token
        if account && account.validate_token!(token)
          unless current && always_ok_usr_id?(account.left_id)
            current = account.left_id
          end
          set_current_from_mark current
        elsif Env.params[:live_token]
          true
          # Used for activations and resets.
          # Continue as anonymous and address problem later
        else
          false
        end
      end

      def set_current_from_mark mark
        self.current_id =
          if mark.to_s =~ /@/
            account = Auth[mark.downcase]
            account && account.active? ? account.left_id : Card::AnonymousID
          else
            mark
          end
      end

      def find_by_token token
        Auth.as_bot do
          Card.search(
            { right_id: Card::AccountID,
              right_plus: [{ id: Card::TokenID }, { content: token.strip }]
              }, "find +*account card by token"
          ).first
        end
      end

      # Encrypts some data with the salt.
      def encrypt password, salt
        Digest::SHA1.hexdigest "#{salt}--#{password}--"
      end

      # find account by email
      def [] email
        email = email.strip.downcase
        Auth.as_bot do
          Card.search(
            { right_id: Card::AccountID,
              right_plus: [{ id: Card::EmailID }, { content: email }]
              }, "find +*account for email(#{email})"
          ).first
        end
      end

      def signin signin_id
        self.current_id = signin_id
        session[:user] = signin_id if session
      end

      def session
        Card::Env[:session]
      end

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

      def current_id
        @@current_id ||= Card::AnonymousID
      end

      def current
        if @@current && @@current.id == current_id
          @@current
        else
          @@current = Card[current_id]
        end
      end

      def current_id= card_id
        @@current = @@as_id = @@as_card = nil
        card_id = card_id.to_i if card_id.present?
        @@current_id = card_id
      end

      def get_user_id user
        case user
        when NilClass then nil
        when Card     then user.id
        when Fixnum   then user
        else Card.fetch_id(user)
        end
      end

      def as given_user
        tmp_id   = @@as_id
        tmp_card = @@as_card

        @@as_id   = get_user_id(given_user)
        @@as_card = nil
        # we could go ahead and set as_card if given a card...

        @@current_id = @@as_id if @@current_id.nil?

        return unless block_given?
        yield
      ensure
        if block_given?
          @@as_id   = tmp_id
          @@as_card = tmp_card
        end
      end

      def as_bot &block
        as Card::WagnBotID, &block
      end

      def among? authzed
        as_card.among? authzed
      end

      def as_id
        @@as_id || current_id
      end

      def as_card
        if @@as_card && @@as_card.id == as_id
          @@as_card
        else
          @@as_card = Card[as_id]
        end
      end

      def signed_in?
        current_id != Card::AnonymousID
      end

      def needs_setup?
        @@simulating_setup_need || (
          !Card.cache.read(SETUP_COMPLETED_KEY) &&
          !Card.cache.write(SETUP_COMPLETED_KEY, account_count > 2)
        )
        # every deck starts with WagnBot and Anonymous account
      end

      def simulate_setup_need! mode=true
        @@simulating_setup_need = mode
      end

      def instant_account_activation
        simulate_setup_need!
        yield
      ensure
        simulate_setup_need! false
      end

      def always_ok?
        usr_id = as_id
        return false unless usr_id
        always_ok_usr_id? usr_id
      end

      def always_ok_usr_id? usr_id
        return true if usr_id == Card::WagnBotID # cannot disable

        always = Card.cache.read("ALWAYS") || {}
        # warn(Rails.logger.warn "Auth.always_ok? #{usr_id}")
        if always[usr_id].nil?
          always = always.dup if always.frozen?
          always[usr_id] =
            !!Card[usr_id].all_roles.find { |r| r == Card::AdministratorID }
          # warn(Rails.logger.warn "update always hash #{always[usr_id]},
          # #{always.inspect}")
          Card.cache.write "ALWAYS", always
        end
        # warn Rails.logger.warn("aok? #{usr_id}, #{always[usr_id]}")
        always[usr_id]
      end

      # PERMISSIONS

      def createable_types
        type_names =
          Auth.as_bot do
            Card.search(
              { type: Card::CardtypeID, return: :name,
                not: { codename: ["in"] + Card.config.non_createable_types } },
              "find createable types"
            )
          end

        type_names.select do |name|
          Card.new(type: name).ok? :create
        end.sort
      end

      private

      def account_count
        as_bot { Card.count_by_wql right: Card[:account].name }
      end
    end
  end
end
