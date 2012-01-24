require 'digest/sha1'

class User < ActiveRecord::Base
  #FIXME: THIS WHOLE MODEL SHOULD BE CALLED ACCOUNT

  # Virtual attribute for the unencrypted password
  attr_accessor :password, :name
  cattr_accessor :current_user, :as_user, :cache

  has_and_belongs_to_many :roles
  belongs_to :invite_sender, :class_name=>'User', :foreign_key=>'invite_sender_id'
  has_many :invite_recipients, :class_name=>'User', :foreign_key=>'invite_sender_id'

  #acts_as_card_extension

  validates_presence_of     :email, :if => :email_required?
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i  , :if => :email_required?
  validates_length_of       :email, :within => 3..100,   :if => :email_required?
  validates_uniqueness_of   :email, :scope=>:login,      :if => :email_required?
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_presence_of     :invite_sender,              :if => :active?
#  validates_uniqueness_of   :salt, :allow_nil => true

  before_validation :downcase_email!
  before_save :encrypt_password
  after_save :reset_instance_cache


  @@rules_user = nil

  class << self
    def current_user
      #warn "cu #{@@current_user}"
      @@current_user ||= User[:anonymous]
    end

    def current_user=(user)
      #warn "cu=(#{user.inspect}) #{@@current_user}, #{@@as_user}"
      @@as_user = nil
      @@current_user = case user
                         when User; user
                         when Card; User.where(:card_id=>user.id).first
                         when Integer; User.where(:card_id=>user).first
                         else User.where(:login=>user.to_s).first
                       end
      #warn "cu= #{@@current_user}, #{@@as_user}"; @@current_user
    end

    def inspect() "#{@@current_user&&@@current_user.login}:#{as_user&&as_user.login}" end

    def as(given_user)
      #warn "as #{given_user.inspect}"
      tmp_user = @@as_user
      @@as_user = given_user.class==User ? User[given_user.id] : User[given_user]
      #warn "as user is #{@@as_user} (#{tmp_user})"
      self.current_user = @@as_user if @@current_user.nil?

      if block_given?
        value = yield
        @@as_user = tmp_user
        return value
      else
        #fail "BLOCK REQUIRED with User#as"
      end
    end

    def as_user()   @@as_user || self.current_user  end
    def read_rules() load_as_rules; @@read_rules    end
    def user_roles() load_as_rules; @@user_roles    end
    def load_as_rules
      if as_user != @@rules_user
        @@rules_user = as_user
        @@user_roles = @@rules_user.all_roles
        @@read_rules = @@rules_user.read_rules
      end
    end

    # FIXME: args=params.  should be less coupled..
    def create_with_card(user_args, card_args, email_args={})
      #warn  "create with(#{user_args.inspect}, #{card_args.inspect}, #{email_args.inspect})"
      @card = (Hash===card_args ? Card.new({:type_id=>Card::UserID}.merge(card_args)) : card_args)
      @user = User.new({:invite_sender=>User.current_user, :status=>'active'}.merge(user_args))
      #warn "user is #{@user.inspect}" unless @user.email
      @user.generate_password if @user.password.blank?
      @user.save_with_card(@card)
      begin
        @user.send_account_info(email_args) if @user.errors.empty? && !email_args.empty?
      end
      [@user, @card]
    end

    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(email, password)
      u = self.find_by_email(email.strip.downcase)
      u && u.authenticated?(password.strip) ? u : nil
    end

    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("#{salt}--#{password}--")
    end

    def [](key)
      #Rails.logger.info "Looking up USER[ #{key}]"

      key = case key
        when Integer
          card_id = key
          @card = Card[card_id]
          "##{key}"
        when Card;
          @card = key
          key.key
        else
          @card = (card_id = Wagn::Codename.code2id(key.to_s)) ?
                    Card[card_id] : @card = Card[key.to_s]
          key.to_s
        end

      usr = self.cache.read(key.to_s)
      return usr if usr

      
      card_id ||= @card && @card.id
      #warn "without #{key.inspect}, #{card_id}"
      if usr = where(:card_id=>card_id).first #preload to be sure these get cached.
        usr.read_rules unless card_id==Card::WagbotID
      end
      #warn "user[#{key.inspect}] #{usr.inspect}"
      self.cache.write(key.to_s, usr)
      code = Wagn::Codename.codename(card_id.to_s) and self.cache.write(code, usr)
      usr
    end

    def logged_in?
      !(current_user.nil? || current_user.card_id==Card::AnonID)
    end

    def no_logins?
      c = self.cache
      !c.read('no_logins').nil? ? c.read('no_logins') : c.write('no_logins', (User.count < 3))
    end

    def always_ok?
      #warn "aok? #{as_user&&as_user.card_id}"
      return false unless usr = as_user
      return true if usr.card_id == Card::WagbotID #cannot disable
      #warn "aok? #{usr}, #{@@current_user}, #{usr.card_id}"

      always = User.cache.read('ALWAYS') || {}
      #warn(Rails.logger.warn "always_ok? #{usr.card_id}")
      if always[usr.card_id].nil?
        always = always.dup if always.frozen?
        always[usr.card_id] = !!usr.all_roles.detect{|r|r==Card::AdminID}
        #warn(Rails.logger.warn "update always hash #{always[usr.card_id]}, #{always.inspect}")
        User.cache.write 'ALWAYS', always
      end
      always[usr.card_id]
    end
    # PERMISSIONS

=begin
    def ok?(task)
      #warn(Rails.logger.warn "ok?(#{task}), #{always_ok?}")
      task = task.to_s
      return false if task != 'read' and Wagn::Conf[:read_only]
      return true  if always_ok?
      #warn(Rails.logger.warn "ok2(#{task}), #{always_ok?}")
      ok_hash.key? task
    end

    def ok!(task)
      if !ok?(task)
        #FIXME -- needs better error message handling
        raise Wagn::PermissionDenied.new(self.new)
      end
    end
=end

  protected
    # FIXME stick this in session? cache it somehow??
    def ok_hash
      usr = User.as_user
      ok_hash = User.cache.read('OK') || {}
      #warn(Rails.logger.warn "ok_hash #{usr.card_id}")
      if ok_hash[usr.card_id].nil?
        ok_hash = ok_hash.dup if ok_hash.frozen?
        ok_hash[usr.card_id] = begin
            usr.all_roles.inject({:role_ids => {}}) do |ok,role_id|
              ok[:role_ids][role_id] = true
              Role[role_id].task_list.each { |t| ok[t] = 1 }
              ok
            end
          end || false
        #warn(Rails.logger.warn "update ok_hash(#{usr.card_id}) #{ok_hash.inspect}")
        User.cache.write 'OK', ok_hash
      end
      r=ok_hash[usr.card_id]
      #warn "ok_h #{r}, #{usr.card_id}, #{ok_hash.inspect}";
    end


  end

#~~~~~~~ Instance

  def reset_instance_cache
    self.class.cache.write(id.to_s, nil)
    self.class.cache.write(login, nil) if login
  end

  def among? authzed
    prties = parties
    #warn(Rails.logger.info "among called.  user = #{self.login}, parties = #{prties.inspect}, authzed = #{authzed.inspect}")
    authzed.each { |auth| return true if prties.member? auth }
    authzed.member? Card::AnyoneID
  end

  def parties
    @parties ||= [all_roles,self.card_id].flatten.reject(&:blank?)
  end

  def read_rules
    return [] if card_id==Card::WagbotID  # avoids infinite loop
    party_keys = ['in', Card::AnyoneID] + parties
    User.as(:wagbot) do
      Card.search(:right=>'*read', :refer_to=>{:id=>party_keys}, :return=>:id).map &:to_i
    end
  end

  def save_with_card(card)
    Rails.logger.info "save with card #{card.inspect}, #{self.inspect}" unless self.email
    User.transaction do
      card = card.refresh if card.frozen?
      card.save
      self.card_id = card.id
      save
      #warn "save_with_card(#{card.name}) #{card.errors}, #{self.errors}"
      card.errors.each do |key,err|
        self.errors.add key,err
      end
    end
#  rescue
#    Rails.logger.info "save with card failed.  #{card.inspect}"
  end

  def accept(card, email_args)
    User.as :wagbot do #what permissions does approver lack?  Should we check for them?
      card.type_id = Card::UserID # Invite Request -> User
      self.status='active'
      self.invite_sender = ::User.current_user
      generate_password
      #warn "user accept #{inspect}, #{card.inspect}"
      save_with_card(card)
    end
    #card.save #hack to make it so last editor is current user.
    self.send_account_info(email_args) if self.errors.empty?
  end

  def send_account_info(args)
    #return if args[:no_email]
    raise(Wagn::Oops, "subject is required") unless (args[:subject])
    raise(Wagn::Oops, "message is required") unless (args[:message])
    begin
      message = Mailer.account_info self, args[:subject], args[:message]
      message.deliver
    rescue Exception=>e
      warn "ACCOUNT INFO DELIVERY FAILED: \n #{args.inspect}\n   #{e.message}, #{e.backtrace*"\n"}"
    end
  end

  def all_roles
    ids=(cr=card.star_rule(:roles)).item_cards.map(&:id)
    #warn "all_roles #{inspect}: #{cr.inspect}, #{ids.inspect}"
    @all_roles ||= (card_id==Card::AnonID ? [] :
      [Card::AuthID] + ids)
      #[Card::AuthID] + card.star_rule(:roles).item_cards.map(&:id))
  end

  def active?()   status=='active'  end
  def blocked?()  status=='blocked' end
  def built_in?() status=='system'  end
  def pending?()  status=='pending' end
  def anonymous?() card_id == Card::AnonID end

  # blocked methods for legacy boolean status
  def blocked=(block)
    if block != '0'
      self.status = 'blocked'
    elsif !built_in?
      self.status = 'active'
    end
  end

  def authenticated?(password)
    crypted_password == encrypt(password) and active?
  end

  def generate_password
    pw=''; 9.times { pw << ['A'..'Z','a'..'z','0'..'9'].map{|r| r.to_a}.flatten[rand*61] }
    self.password = pw
    self.password_confirmation = self.password
  end

  def to_s
    "#<#{self.class.name}:#{login.blank? ? email : login}}>"
  end

  def mocha_inspect
    to_s
  end

  #before validation
  def downcase_email!
    self.email=self.email.downcase if self.email
  end

  def card()
    @card && @card.id == card_id ? @card : @card = Card[card_id]
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

