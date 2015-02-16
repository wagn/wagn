# -*- encoding : utf-8 -*-

class Card
  module Auth
    @@as_card = @@as_id = @@current_id = @@current = @@simulating_setup_need = nil

    NON_CREATEABLE_TYPES = %w{ signup setting set } # NEED API
    NEED_SETUP_KEY = 'NEED_SETUP'

    #after_save :reset_instance_cache

    class << self

      # Authenticates a user by their login name and unencrypted password.  
      def authenticate email, password
        accounted = Auth[ email ]
        if accounted and account = accounted.account and account.active?
          if Card.config.no_authentication or password_authenticated?( account, password.strip )
            accounted.id
          end
        end
      end

      def password_authenticated? account, password
        account.password == encrypt( password, account.salt )
      end


      # Encrypts some data with the salt.
      def encrypt password, salt
        Digest::SHA1.hexdigest "#{salt}--#{password}--"
      end

      # find accounted by email
      def [] email
        Auth.as_bot do
          Card.search( :right_plus=>[
            {:id=>Card::AccountID},
            {:right_plus=>[{:id=>Card::EmailID},{ :content=>email.strip.downcase }]}
          ]).first
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
            if card_id=session[:user] and Card.exists? card_id
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
        @@current_id = card_id
      end

      def get_user_id user
        case user
        when NilClass;   nil
        when Card    ;   user.id
        when Integer ;   user
        else
          user = user.to_s
          Card::Codename[user] or (cd=Card[user] and cd.id)
        end
      end

      def as given_user
        tmp_id, tmp_card = @@as_id, @@as_card
        @@as_id, @@as_card = get_user_id( given_user ), nil  # we could go ahead and set as_card if given a card...

        @@current_id = @@as_id if @@current_id.nil?

        if block_given?
          value = yield
          @@as_id, @@as_card = tmp_id, tmp_card
          return value
        else
          #fail "BLOCK REQUIRED with Card#as"
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
        if @@as_card and @@as_card.id == as_id
          @@as_card
        else
          @@as_card = Card[as_id]
        end
      end

      def signed_in?
        current_id != Card::AnonymousID
      end

      def needs_setup?
        test = Card.cache.read NEED_SETUP_KEY
        !test.nil? ? test : begin
          @@simulating_setup_need or Card.cache.write( NEED_SETUP_KEY, (account_count < 3) ) # 3, because
        end
      end
    
      def simulate_setup_need! mode=true
        @@simulating_setup_need = mode
        Card.cache.write NEED_SETUP_KEY, nil
      end
    

      def always_ok?
        #warn Rails.logger.warn("aok? #{as_id}, #{as_id&&Card[as_id].id}")
        return false unless usr_id = as_id
        return true if usr_id == Card::WagnBotID #cannot disable

        always = Card.cache.read('ALWAYS') || {}
        #warn(Rails.logger.warn "Auth.always_ok? #{usr_id}")
        if always[usr_id].nil?
          always = always.dup if always.frozen?
          always[usr_id] = !!Card[usr_id].all_roles.detect{|r|r==Card::AdministratorID}
          #warn(Rails.logger.warn "update always hash #{always[usr_id]}, #{always.inspect}")
          Card.cache.write 'ALWAYS', always
        end
        #warn Rails.logger.warn("aok? #{usr_id}, #{always[usr_id]}")
        always[usr_id]
      end
      # PERMISSIONS


      def createable_types
        type_names = Auth.as_bot do
          Card.search :type=>Card::CardtypeID, :return=>:name, :not => { :codename => ['in'] + NON_CREATEABLE_TYPES }
        end
        type_names.reject do |name|
          !Card.new( :type=>name ).ok? :create
        end.sort
      end

      private
  
      def account_count
        as_bot { Card.count_by_wql :right=>Card[:account].name }
      end

    end
  end
end
