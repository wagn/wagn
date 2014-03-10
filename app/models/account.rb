# -*- encoding : utf-8 -*-

class Account
  @@as_card = @@as_id = @@current_id = @@current = nil

  #after_save :reset_instance_cache

  class << self
    def admin()          self[ Card::WagnBotID    ]   end
    def as_user()        self[ Account.as_id      ]   end

    def create_ok?
      base  = Card.new :name=>'dummy*', :type_id=>Card.default_accounted_type_id
      trait = Card.new :name=>"dummy*+#{Card[:account].name}"
      base.ok?(:create) && trait.ok?(:create)
    end

    # Authenticates a user by their login name and unencrypted password.  
    def authenticate email, password
      accounted = find_accounted_by_email email
      if accounted and account = accounted.account
        if Wagn.config.no_authentication or password_authenticated?( account, password.strip )
          accounted.id
        end
      end
    end

    def password_authenticated? card, password
      card.password == encrypt(password, card.salt)
    end
    
    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("#{salt}--#{password}--")
    end

    # Caching by email
    def [] mark
      cache_key = "EMAIL-#{mark.to_name.key}"
      cache_val = Card.cache.read( cache_key ) || begin
        card = find_accounted_by_email mark
        Card.cache.write cache_key, ( card ? card.id : :missing )
      end
      cache_val == :missing ? nil : Card[cache_val]
    end
    
    def find_accounted_by_email email
      Account.as_bot do
        Card.search( :right_plus=>[
          {:id=>Card::AccountID},
          {:right_plus=>[{:id=>Card::EmailID},{ :content=>email.strip.downcase }]}
        ]).first
      end
    end
    
#----------
    def current_id
      @@current_id ||= Card::AnonID
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

    def logged_in?
      current_id != Card::AnonID
    end

    def no_logins?()
      c = Card.cache
      !c.read('no_logins').nil? ? c.read('no_logins') : c.write('no_logins', (account_count < 3))
    end
    
    def account_count
      Card.count_by_wql :right=>Card[:account].name
    end

    def always_ok?
      #warn Rails.logger.warn("aok? #{as_id}, #{as_id&&Card[as_id].id}")
      return false unless usr_id = as_id
      return true if usr_id == Card::WagnBotID #cannot disable

      always = Card.cache.read('ALWAYS') || {}
      #warn(Rails.logger.warn "Account.always_ok? #{usr_id}")
      if always[usr_id].nil?
        always = always.dup if always.frozen?
        always[usr_id] = !!Card[usr_id].all_roles.detect{|r|r==Card::AdminID}
        #warn(Rails.logger.warn "update always hash #{always[usr_id]}, #{always.inspect}")
        Card.cache.write 'ALWAYS', always
      end
      #warn Rails.logger.warn("aok? #{usr_id}, #{always[usr_id]}")
      always[usr_id]
    end
    # PERMISSIONS


  protected
    # FIXME stick this in session? cache it somehow??
    def ok_hash
      usr_id = Account.as_id
      ok_hash = Card.cache.read('OK') || {}
      #warn(Rails.logger.warn "ok_hash #{usr_id}")
      if ok_hash[usr_id].nil?
        ok_hash = ok_hash.dup if ok_hash.frozen?
        ok_hash[usr_id] = begin
            Card[usr_id].all_roles.inject({:role_ids => {}}) do |ok,role_id|
              ok[:role_ids][role_id] = true
              ok
            end
          end || false
        #warn(Rails.logger.warn "update ok_hash(#{usr_id}) #{ok_hash.inspect}")
        Card.cache.write 'OK', ok_hash
      end
      r=ok_hash[usr_id]
      #warn "ok_h #{r}, #{usr_id}, #{ok_hash.inspect}";
    end

  public

    NON_CREATEABLE_TYPES = %w{ account_request setting set }

    def createable_types
      type_names = Account.as_bot do
        Card.search :type=>Card::CardtypeID, :return=>:name, :not => { :codename => ['in'] + NON_CREATEABLE_TYPES }
      end
      type_names.reject do |name|
        !Card.new( :type=>name ).ok? :create
      end.sort
    end

    def reset_cache_item card_id, email=nil
      cache.write "~#{card_id}", nil
      cache.write email, nil if email
    end

  end

end
