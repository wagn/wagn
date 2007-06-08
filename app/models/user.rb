require 'digest/sha1'
require_dependency "acts_as_card_extension"

class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  cattr_accessor :current_user
  has_and_belongs_to_many :roles
  acts_as_card_extension
  
 
  validates_presence_of     :email
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email 
  
  before_save :encrypt_password
  
  class << self
    def active_users
      self.find(:all) #, :conditions=>"activated_at is not null")
    end 
                        
    def as_admin
      self.current_user = User.find_by_login('admin')
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
  end 

  def authenticated?(password)
    crypted_password == encrypt(password) and !blocked
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

#hack for instiki integration
unless defined? Author
  Author=User
end
