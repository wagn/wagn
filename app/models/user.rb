 require 'digest/sha1'
require_dependency "acts_as_card_extension"

class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password, :name
  cattr_accessor :current_user
  
  has_and_belongs_to_many :roles
  belongs_to :invite_sender, :class_name=>'User', :foreign_key=>'invite_sender_id'
  has_many :invite_recipients, :class_name=>'User', :foreign_key=>'invite_sender_id'

  acts_as_card_extension
   
  validates_presence_of     :email, :if => :not_openid?
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :if => :not_openid?
  validates_length_of       :email, :within => 3..100,   :if => :not_openid?
  validates_uniqueness_of   :email,                      :if => :not_openid?  
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_presence_of     :invite_sender,              :if => :active?
#  validates_uniqueness_of   :salt, :allow_nil => true
  
  before_save :encrypt_password
  
  def all_roles
    @cached_roles ||= (login=='anon' ? [Role[:anon]] : 
      roles + [Role[:anon], Role[:auth]])
  end  
  
  class << self
    def find_or_create_by_identity_url(url)
      if u= self.find_by_identity_url(url)
        u
      else
        User.create_with_card(:identity_url=>url)
      end
    end
    
    # FIXME: args=params.  should be less coupled..
    def create_with_card(args={})
      ## CREATE CARD FOR THE NEW USER
      @card_name = args[:card][:name]
      @card = ::Card.find_by_name(@card_name) || ::Card::User.new( args[:card] )
      
      if @card.type == 'InvitationRequest' 
        @user = @card.extension or raise "Blam.  InvitationRequest should've been connected to a user"    
        User.as :admin do
          @card.type = 'User'  # change from Invite Request -> User
          dummy = Card::User.new; dummy.send(:set_defaults)
          @card.permit :edit, dummy.who_can(:edit)
          @card.save!
        end
        @user.status='active'
        @user.invite_sender = ::User.current_user
      elsif @card.type=='User' and !@card.extension
        @user = User.new( args[:user].merge( :invite_sender_id=>User.current_user.id )) 
        @user.status='active'
      else
        @card.errors.add(:name, "has already been taken")
        raise ActiveRecord::RecordInvalid.new(@card)
      end
      @user.generate_password if @user.password.blank?
      
      ## ADD USER
      User.transaction do 
        @card.extension = @user
        begin 
          @user.save!
        rescue ActiveRecord::RecordInvalid => err
          err.record.errors.each do |key,err|
            @card.errors.add key,err
          end
          raise ActiveRecord::RecordInvalid.new(@card)
        end
        #User.as :admin do ## fixme was breaking on templated user card on permission to change content ? 
          @card.save!
        #end    
        raise(Wagn::Oops, "Invitation Email subject is required") unless (args[:email] and args[:email][:subject])
        raise(Wagn::Oops, "Invitation Email message is required") unless (args[:email] and args[:email][:message])
        Notifier.deliver_account_info(@user, args[:email][:subject], args[:email][:message])
      end  
      @user
    end
    #alias_method_chain :create, :card
    
    
    def current_user
      @@current_user ||= find_by_login('anon')  
    end
    
    def current_user=(user)
      @@current_user = user
    end
    
    def active_users
      self.find(:all, :conditions=>"status='active'")
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
  end 

  def active?
    status == 'active'
  end

  def anonymous?
    login == 'anon'
  end

  def authenticated?(password) 
    crypted_password == encrypt(password) and active?      
    #true
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

