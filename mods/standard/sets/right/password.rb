# -*- encoding : utf-8 -*-

include Card::Set::All::Permissions::Accounts

view :editor do |args|
  card.content = ''
  _final_phrase_type_editor args
end

view :raw do |args|
  '<em>encrypted</em>'
end

event :encrypt_password, :on=>:save, :after=>:process_subcards, :when=>proc{ |c| !c.importing_passwords? } do
  salt = (left && left.salt)
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

event :validate_password_present, :on=>:update, :before=>:approve do
  abort :success if content.blank?
end

=begin
def check_password?
  !built_in? &&
  !pending?  &&
  !password.blank?
end
=end

def importing_passwords?
  #FIXME - this is not the correct mechanism for this.  needs to be a way to turn off events from the call (where authorized)
  defined? UserDataToCards
end

def ok_to_read
  is_own_account? ? true : super
end