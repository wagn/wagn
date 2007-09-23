 require 'digest/sha1'
require_dependency "acts_as_card_extension"

class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  cattr_accessor :current_user
  
  #attr_protected :invite_sender, :status    
  cattr_accessor :cache  
  self.cache = {}
 
  has_and_belongs_to_many :roles
  belongs_to :invite_sender, :class_name=>'User', :foreign_key=>'invite_sender_id'
  has_many :invite_recipients, :class_name=>'User', :foreign_key=>'invite_sender_id'

  acts_as_card_extension
   
  validates_presence_of     :email
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_length_of       :email, :within => 3..100
  validates_uniqueness_of   :email 
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_presence_of     :invite_sender,              :if => :active?
  
  before_save :encrypt_password
  
  def all_roles
    @cached_roles ||= (login=='anon' ? [Role[:anon]] : 
      roles + [Role[:anon], Role[:auth]])
  end  
  
  class << self
    
    def current_user
      System.current_user
    end
    
    def current_user=(user)
      System.current_user = user
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
      self.cache[login.to_s] ||= User.find_by_login(login.to_s)
    end
  end 

  def createable_cardtypes #FIXME -- needs optimizing.  badly.
    #@createables ||= Card::Cardtype.find(:all, :order=>'name').map do |ct| 
    Card::Cardtype.find(:all, :order=>'name').map do |ct| 
      next if !ct.ok? :create
      next if ct.extension.class_name == 'InvitationRequest'
      { :codename=> ct.extension.class_name, :name=> ct.name }
    end.compact
  end

  def active?
    status == 'active'
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
    crypted_password.blank? or not password.blank?
  end   
  
end

