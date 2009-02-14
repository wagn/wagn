 require 'digest/sha1'
require_dependency "acts_as_card_extension"

class User < ActiveRecord::Base
  #FIXME: THIS WHOLE MODEL SHOULD BE CALLED ACCOUNT
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password, :name
  cattr_accessor :current_user
  
  has_and_belongs_to_many :roles
  belongs_to :invite_sender, :class_name=>'User', :foreign_key=>'invite_sender_id'
  has_many :invite_recipients, :class_name=>'User', :foreign_key=>'invite_sender_id'

  acts_as_card_extension
   
  validates_presence_of     :email, :if => :not_openid?
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i  #, :if => :not_openid?
  validates_length_of       :email, :within => 3..100    #,:if => :not_openid?
  validates_uniqueness_of   :email                       #,:if => :not_openid?  
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_presence_of     :invite_sender,              :if => :active?
#  validates_uniqueness_of   :salt, :allow_nil => true
  
  before_save :encrypt_password
  
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
      self.current_user = given_user.class==User ? given_user : User.find_by_login(given_user.to_s)
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
      @card = Card::User.new card_args 
      @user = User.new({:invite_sender=>User.current_user, :status=>'active'}.merge(user_args))
      @user.generate_password if @user.password.blank?

      @user.save_with_card!(@card)
      [@user, @card]
    end
    
    def create_ok?
      Card::User.create_ok? && System.ok?(:add_accounts_to_cards)
    end
    
    def active_users
      self.find(:all, :conditions=>"status='active'")
    end 
    
    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(email, password)
      u = self.find_by_email(email)
      u && u.authenticated?(password) ? u : nil
    end

    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("#{salt}--#{password}--")
    end    
    
    def [](login)
      User.find_by_login(login.to_s)
    end

    # OPENID - on hold
    #def find_or_create_by_identity_url(url)
    #  self.find_by_identity_url(url) || User.create_with_card(:identity_url=>url)
    #end
  end 

  ## INSTANCE METHODS

  def save_with_card!(card)
    User.transaction do 
      card.extension = self
      begin 
        save!
      rescue ActiveRecord::RecordInvalid => err
        err.record.errors.each do |key,err|
          card.errors.add key,err
        end
        raise ActiveRecord::RecordInvalid.new(card)
      end
      card.save!
    end      
  end
  
  def accept
    User.as :admin do #what permissions does approver lack?  Should we check for them?
      card.type = 'User'  # change from Invite Request -> User
      card.permit :edit, Card.new(:type=>'User').who_can(:edit) #give default user permissions
      card.save!
    end
    card.save #hack to make it so last editor is current user.
    status='active'
    invite_sender = ::User.current_user
    save!
  end

  def send_account_email(args)
    return if args[:no_email]
    raise(Wagn::Oops, "subject is required") unless (args[:subject])
    raise(Wagn::Oops, "message is required") unless (args[:message])
    Notifier.deliver_account_info(self, args[:subject], args[:message])
  end  

  def all_roles
    @cached_roles ||= (login=='anon' ? [Role[:anon]] : 
      roles + [Role[:anon], Role[:auth]])
  end  

  def active?
    status == 'active'
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

   
  protected
  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end
   
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    not_openid? && (crypted_password.blank? or not password.blank?)
  end
 
  def not_openid?
    identity_url.blank?
  end

end

