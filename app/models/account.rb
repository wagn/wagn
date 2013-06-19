# -*- encoding : utf-8 -*-
require_dependency 'user'

class Account
  @@as_card = @@as_id = @@current_id = @@current = @@user = nil

  #after_save :reset_instance_cache

  class << self
    def admin()          self[ Card::WagnBotID    ]   end
    def as_user()        self[ Account.as_id      ]   end
    def user()           self[ Account.current_id ]   end

    def cache()          Wagn::Cache[Account]         end

    def create_ok?
      base  = Card.new :name=>'dummy*', :type_id=>Card::UserID
      trait = Card.new :name=>"dummy*+#{Card[:account].name}"
      base.ok?(:create) && trait.ok?(:create)
    end

    # FIXME: args=params.  should be less coupled..
    def create_with_card user_args, card_args, email_args={}
      card_args[:type_id] ||= Card::UserID
      @card = Card.fetch card_args[:name], :new => card_args
      Account.as_bot do
        @account = User.new(user_args)
        @account.status = 'active' unless user_args.has_key? :status
        #Rails.logger.warn "create_wcard #{@account.inspect}, #{user_args.inspect}"
        @account.generate_password if @account.password.blank?
        @account.save_with_card(@card)
        @account.send_account_info(email_args) if @card.errors.empty? && !email_args.empty?
      end
      [@account, @card]
    end

    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(email, password)
      u = User.find_by_email(email.strip.downcase)
      u && u.authenticated?(password.strip) ? u.card_id : nil
    end

    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("#{salt}--#{password}--")
    end

    # Account caching
    def [] mark
      if mark
        cache_key = Integer === mark ? "~#{mark}" : mark
        cached_val = cache.read cache_key
        case cached_val
        when :missing; nil
        when nil
          val = if Integer === mark
            User.find_by_card_id mark
          else
            User.find_by_email mark
          end
          cache.write cache_key, ( val || :missing )
          val
        else
          cached_val
        end
      end
    end
    
    def delete_cardless
      where( Card.where( :id=>arel_table[:card_id] ).exists.not ).delete_all
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

    def user
      if @@user && @@user.card_id == current_id
        @@user
      else
        @@user = Account[ current_id ]
      end
    end

    def current_id= card_id
      @@user = @@current = @@as_id = @@as_card = nil
      @@current_id = card_id
    end

    def get_user_id user
      case user
      when NilClass;   nil
      when User    ;   user.card_id
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
      !c.read('no_logins').nil? ? c.read('no_logins') : c.write('no_logins', (User.count < 3))
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
