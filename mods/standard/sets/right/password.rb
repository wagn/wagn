# -*- encoding : utf-8 -*-

  
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