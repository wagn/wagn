# -*- encoding : utf-8 -*-

view :raw do |args|
  'Passwords are encrypted and unavailable for viewing'
end

event :encrypt_password, :on=>:save, :after=>:approve do
  if updates.for :content
    self.content = Account.encrypt content, left.salt
  end
end

  
#  validates :password, :length => { :within => 5..40 }, :confirmation=>true, :if=>:check_password?    
#  validates :password_confirmation, :presence=>true, :if=>:check_password?
#
## before save
#def encrypt_password
#  self.crypted_password = Account.encrypt password, salt
#end
#
#def check_password?
#  !built_in? &&
#  !pending?  &&
#  !password.blank?
#end