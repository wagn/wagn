require 'digest/sha1'

class User < ActiveRecord::Base
  #FIXME: THIS WHOLE MODEL SHOULD BE CALLED ACCOUNT
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password, :name
  cattr_accessor :current_user
  
  has_and_belongs_to_many :roles
  belongs_to :invite_sender, :class_name=>'User', :foreign_key=>'invite_sender_id'
  has_many :invite_recipients, :class_name=>'User', :foreign_key=>'invite_sender_id'

  acts_as_card_extension
   
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
  
  cattr_accessor :cache  
  self.cache = {}
  
  class << self
    # CURRENT USER
    def current_user
      @@current_user ||= find_by_login('anon')  
    end
    
    def current_user=(user)
      @@current_user = user
    end
   
    def as(given_user)
      tmp_user = self.current_user
      self.current_user = given_user.class==User ? given_user : User[given_user]
      if block_given?
        value = yield
        self.current_user = tmp_user
        return value
      else
        current_user
      end
    end
    
    
    # FIXME: args=params.  should be less coupled..
    def create_with_card(user_args, card_args, email_args={})
      @card = (Hash===card_args ? Card.new({'type'=>'User'}.merge(card_args)) : card_args) 
      @user = User.new({:invite_sender=>User.current_user, :status=>'active'}.merge(user_args))
      @user.generate_password if @user.password.blank?
      @user.save_with_card(@card)
      begin
        @user.send_account_info(email_args) if @user.errors.empty? && !email_args.empty?
      end
      [@user, @card]
    end

    def active_users
      self.find(:all, :conditions=>"status='active'")
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
    
    def [](login)
      login=login.to_s
      login.blank? ? nil : (self.cache[login] ||= User.find_by_login(login)) 
    end

    def no_logins?
      self.cache[:no_logins] ||= User.count < 3
    end
    
    def clear_cache
      self.cache = {}
    end

    # OPENID - on hold
    #def find_or_create_by_identity_url(url)
    #  self.find_by_identity_url(url) || User.create_with_card(:identity_url=>url)
    #end
  end 

  ## INSTANCE METHODS

  def save_with_card(card)
    #fail "save with card #{card.inspect}"
    User.transaction do
      save
      card.extension = self
      card.save
      card.errors.each do |key,err|
        next if key=='extension'
        self.errors.add key,err
      end
      raise ActiveRecord::RecordInvalid.new(self) if !self.errors.empty?
    end
  rescue  
  end
      

  def accept(email_args)
    User.as :wagbot  do #what permissions does approver lack?  Should we check for them?
      card.type = 'User'  # change from Invite Request -> User
      card.permit :edit, Card.new(:type=>'User').who_can(:edit) #give default user permissions
      self.status='active'
      self.invite_sender = ::User.current_user
      generate_password
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
      Mailer.deliver_account_info(self, args[:subject], args[:message])
    rescue; warn("ACCOUNT INFO DELIVERY FAILED: \n #{args.inspect}")
    end
  end  

  def all_roles
    @cached_roles ||= (login=='anon' ? [Role[:anon]] : 
      roles + [Role[:anon], Role[:auth]])
  end  

  def active?
    status=='active'
  end
  def blocked?
    status=='blocked'
  end
  def built_in?
    status=='system'
  end
  def pending?
    status=='pending'
  end

  # blocked methods for legacy boolean status
  def blocked=(block)
    if block != '0'
      self.status = 'blocked'
    elsif !built_in?
      self.status = 'active'
    end
  end

  def anonymous?
    login == 'anon'
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
    email.downcase! if email
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
     !built_in? && !pending? && not_openid? && (crypted_password.blank? or not password.blank?)
  end
 
  def not_openid?
    identity_url.blank?
  end

end

