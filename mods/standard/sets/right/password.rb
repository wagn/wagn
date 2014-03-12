# -*- encoding : utf-8 -*-

view :raw do |args|
  'Passwords are encrypted and unavailable for viewing'
end

event :encrypt_password, :on=>:save, :after=>:process_subcards, :when=>proc{ |c| !c.importing_passwords? } do
  salt = left.salt
  unless salt.present? or salt = Wagn::Env[:salt] #(hack)
    errors.add :password, 'need a valid salt'
  end
  if updates.for :content
    self.content = Account.encrypt content, salt
  end
end

event :validate_password, :on=>:save, :before=>:approve, :when=>proc{ |c| !c.importing_passwords? } do
  unless content.length > 3
    errors.add :password, 'must be at least 4 characters'
  end
end


=begin
def check_password?
  !built_in? &&
  !pending?  &&
  !password.blank?
end
=end

def importing_passwords?
  #FIXME - this is not the correct mechanism for this
  defined? UserDataToCards
end

def permit action, verb=nil
  is_own_account? ? true : super(action, verb)
end

def ok_to_read
  is_own_account? ? true : super
end