# -*- encoding : utf-8 -*-
require 'digest'

# Virtual attributes for the unencrypted password
attr_accessor :password, :password_confirmation

card_accessor :email,               :limit => 100, :type=>:phrase
card_accessor :crypted_password,    :limit => 40, :type=>:phrase
card_accessor :salt,                :limit => 42, :type=>:phrase
card_accessor :status,              :default => "request", :type=>:phrase

event :valid_account, :before=>:save do

  downcase_email!

  Rails.logger.warn "valid_account #{email.inspect}, #{inspect}, #{self.crypted_password}, #{crypted_password}"
  # validations: email
  if !built_in? and crypted_password.blank?
  Rails.logger.warn "valid_account #{email.inspect}, #{inspect}, #{self.crypted_password}, #{crypted_password}"
    if email.empty?
      errors.add :email, "cannot be blank"
    elsif email !~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      errors.add :email, "bad format"
    elsif email.length > 100
      errors.add :email, "too long"
    end
  end

  if password_required?
Rails.logger.warn "pw req -- errors on acct valid? #{errors.any?}"
    if password.nil? || password.empty?
      errors.add :password, "can't be blank"
    elsif password.length < 5 
      errors.add :password, "too short"
    elsif password.length > 40
      errors.add :password, "too long"
    elsif password_confirmation.empty?
      errors.add :password_confirmation, "cannot be blank"
    elsif password != password_confirmation
      errors.add :password, "does not match"
    end
  end

Rails.logger.warn "errors on acct valid? #{errors.any?}"
  return false if errors.any?

  true
end

event :encrypt_password, :before=>:save do
  return true if password.blank?
  self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
  self.crypted_password = encrypt(password)
end

#event :reset_instance_cache, :after=>:save do
#  Account.reset_cache_item left_id, email
#end

def accept card, email_args
  Account.as_bot do #what permissions does approver lack?  Should we check for them?
    card.type_id = Card::UserID # Invite Request -> User
    self.status='active'
    generate_password
    r=save
    Rails.logger.warn "accept #{inspect}, #{card.inspect}, #{self.errors.full_messages*", "} R:#{r}"; r
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
def pending?  ;
Rails.logger.warn "p? status #{self.status}, #{status}"
status=='pending' end

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
  "#<#{self.class.name}:#{name.blank? ? email : name}}>"
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

#protected

# Encrypts the password with the user salt
def encrypt(password)
  Account.encrypt(password, salt)
end

def password_required?
  !built_in? &&
  !pending?  &&
  #not_openid? &&
  (crypted_password.blank? or not password.blank?)
end


