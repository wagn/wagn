# -*- encoding : utf-8 -*-
require 'digest'

class User < ActiveRecord::Base

  # Virtual attribute for the unencrypted password
  attr_accessor :password, :name

  validates :card_id,    :presence=>true, :uniqueness=>true
  validates :account_id, :presence=>true, :uniqueness=>true

  validates :email, :presence=>true, :if=>:email_required?,
    :uniqueness => { :scope   => :login                                      },
    :format     => { :with    => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i },
    :length     => { :maximum => 100                                         }
  
  validates :password, :length => { :within => 5..40 }, :confirmation=>true, :if=>:check_password?    
  validates :password_confirmation, :presence=>true, :if=>:check_password?
  
    

  before_validation :downcase_email!
  before_save :encrypt_password
  after_save :reset_instance_cache

  class << self
    def delete_cardless
      where( Card.where( :id=>arel_table[:card_id] ).exists.not ).delete_all
    end
  end

#~~~~~~~ Instance

  def reset_instance_cache
    Account.reset_cache_item card_id, email
  end

  def send_account_info args
    raise Wagn::Oops, "subject and message required" unless args[:subject] && args[:message]
    begin
      if password.blank?
        generate_password
        save!
      end
      
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

#protected

  # Encrypts the password with the user salt
  def encrypt password
    Account.encrypt password, salt
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

  def check_password?
    !built_in? &&
    !pending?  &&
    !password.blank?
  end

end

