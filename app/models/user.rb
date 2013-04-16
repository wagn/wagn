# -*- encoding : utf-8 -*-
require 'digest'

class User < ActiveRecord::Base

  # Virtual attribute for the unencrypted password
  attr_accessor :password, :name

  validates_presence_of     :card_id
  validates_uniqueness_of   :card_id
  validates_presence_of     :account_id
  validates_uniqueness_of   :account_id
  validates_presence_of     :email, :if => :email_required?
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i  , :if => :email_required?
  validates_length_of       :email, :within => 3..100,   :if => :email_required?
  validates_uniqueness_of   :email, :scope=>:login,      :if => :email_required?
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?

  before_validation :downcase_email!
  before_save :encrypt_password
  after_save :reset_instance_cache

  class << self
    def admin()          self[ Card::WagnBotID    ]   end
    def as_user()        self[ Account.as_id      ]   end
    def user()           self[ Account.current_id ]   end

    def cache()          Wagn::Cache[User]            end

    def create_ok?
      base  = Card.new :name=>'dummy*', :type_id=>Card::UserID
      trait = Card.new :name=>"dummy*+#{Card[:account].name}"
      base.ok?(:create) && trait.ok?(:create)
    end

    # FIXME: args=params.  should be less coupled..
    def create_with_card user_args, card_args, email_args={}
      card_args[:type_id] ||= Card::UserID
      @card = Card.fetch(card_args[:name], :new=>card_args)
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
      u = self.find_by_email(email.strip.downcase)
      u && u.authenticated?(password.strip) ? u.card_id : nil
    end

    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("#{salt}--#{password}--")
    end

    # User caching
    def [] mark
      if mark
        cache_key = Integer === mark ? "~#{mark}" : mark
        cached_val = cache.read cache_key
        case cached_val
        when :missing; nil
        when nil
          val = if Integer === mark
            find_by_card_id mark
          else
            find_by_email mark
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
  end

#~~~~~~~ Instance

  def reset_instance_cache
    self.class.cache.write "~#{card_id}", nil
    self.class.cache.write email, nil if email
  end

  def save_with_card card
    User.transaction do
      card = card.refresh
      account = card.fetch :trait=>:account, :new=>{}
      if card.save
        if account.save
          self.account_id = account.id
          self.card_id = card.id
          save
        end
      end

      account.errors.each do |key,err|
        card.errors.add key,err
      end
      self.errors.each do |key,err|
        card.errors.add key,err
      end
      if card.errors.any?
        card.expire_pieces
        raise ActiveRecord::Rollback 
      end
      true
    end
  end

  def accept card, email_args
    Account.as_bot do #what permissions does approver lack?  Should we check for them?
      card.type_id = Card::UserID # Invite Request -> User
      self.status='active'
      generate_password
      r=save_with_card(card)
      #Rails.logger.warn "accept #{inspect}, #{card.inspect}, #{self.errors.full_messages*", "} R:#{r}"; r
    end
    #card.save #hack to make it so last editor is current user.
    self.send_account_info(email_args) if card.errors.empty?
  end

  def send_account_info args
    raise Wagn::Oops, "subject and message required" unless args[:subject] && args[:message]
    begin
      args.merge! :to => self.email, :password => self.password
      #warn "account infor args: #{args}"
      message = Mailer.account_info Card[card_id], args
      message.deliver
    rescue Exception=>e
      Airbrake.notify e if Airbrake.configuration.api_key
      Rails.logger.info("ACCOUNT INFO DELIVERY FAILED: \n #{args.inspect}\n   #{e.message}, #{e.backtrace*"\n"}")
    end
  end

  def anonymous?; card_id == Card::AnonID end

  def active?   ; status=='active'  end
  def blocked?  ; status=='blocked' end
  def built_in? ; status=='system'  end
  def pending?  ; status=='pending' end

  # blocked methods for legacy boolean status
  def blocked= block
    if block == true
      self.status = 'blocked'
    elsif !built_in?
      self.status = 'active'
    end
  end

  def authenticated?(password)
    crypted_password == encrypt(password) and active?
  end

  PW_CHARS = ['A'..'Z','a'..'z','0'..'9'].map(&:to_a).flatten

  def generate_password
    self.password_confirmation = self.password =
      9.times.map { PW_CHARS[rand*61] }*''
  end

  def to_s
    "#<#{self.class.name}:#{login.blank? ? email : login}}>"
  end

  def mocha_inspect
    to_s
  end

  #before validation
  def downcase_email!
    if e = self.email and e != e.downcase
      self.email=e.downcase
    end
  end

protected

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  # before save
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def email_required?
    !built_in?
  end

  def password_required?
    !built_in? &&
    !pending?  &&
    #not_openid? &&
    (crypted_password.blank? or not password.blank?)
  end

end

