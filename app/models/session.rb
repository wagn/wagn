class Session
  @@as_card = @@as_id = @@user_id = @@user_card = @@user = nil

  class << self
    def user_id
      @@user_id ||= Card::AnonID
    end
  
    def user_card
      if @@user_card && @@user_card.id == user_id
        @@user_card
      else
        @@user_card = Card[user_id]
      end
    end
  
    def user
      if @@user && @@user.card_id == user_id
        @@user
      else
        @@user = user_card.to_user
      end
    end

    def user= user
      Rails.logger.info "\n\n~~~~~~~~~SETTING NEW USER #{user.inspect}~~~~~~~~~\n\n"
      
      @@user = @@user_card = @@as_id = @@as_card = nil
      @@user_id = get_user_id user
      
    end

    def get_user_id user  #FIXME - should handle codenames
      case user
      when NilClass;   nil
      when User    ;   user.card_id
      when Card    ;   user.id
      when Integer ;   user
      else
        user = user.to_s
        Wagn::Codename[user] or (cd=Card[user] and cd.id)
      end
    end

    def as given_user
      tmp_id, tmp_card = @@as_id, @@as_card
      @@as_id, @@as_card = get_user_id( given_user ), nil  # we could go ahead and set as_card if given a card...

      @@user_id = @@as_id if @@user_id.nil?

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
      @@as_id || user_id
    end
    
    def as_card
      if @@as_card and @@as_card.id == as_id
        @@as_card
      else
        @@as_card = Card[as_id]
      end
    end

    def logged_in?() user_id != Card::AnonID end

    def no_logins?()
      c = Card.cache
      !c.read('no_logins').nil? ? c.read('no_logins') : c.write('no_logins', (User.count < 3))
    end

    def always_ok?
      #warn Rails.logger.warn("aok? #{as_id}, #{as_id&&Card[as_id].id}")
      return false unless usr_id = as_id
      return true if usr_id == Card::WagnBotID #cannot disable

      always = Card.cache.read('ALWAYS') || {}
      #warn(Rails.logger.warn "Session.always_ok? #{usr_id}")
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
      usr_id = Session.as_id
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
      type_names = Session.as_bot do
        Card.search :type=>Card::CardtypeID, :return=>:name, :not => { :codename => ['in'] + NON_CREATEABLE_TYPES }
      end
      type_names.reject do |name|
        !Card.new( :type=>name ).ok? :create
      end.sort
    end
  end


end