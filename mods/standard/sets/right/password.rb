# -*- encoding : utf-8 -*-

view :raw do |args|
  'Passwords are encrypted and unavailable for viewing'
end

event :encrypt_password, :on=>:save, :after=>:approve do
  if updates.for :content
    self.content = Account.encrypt content, left.salt
  end
end

event :validate_password, :on=>:save, :before=>:approve do
  unless content.length > 3
    errors.add :password, 'must be at least 4 characters'
  end
end

#  validates :password, :length => { :within => 5..40 }, :confirmation=>true, :if=>:check_password?
=begin
def check_password?
  !built_in? &&
  !pending?  &&
  !password.blank?
end
=end

def permit action, verb=nil
  is_own_account? ? true : super(action, verb)
end

def ok_to_read
  is_own_account? ? true : super
end