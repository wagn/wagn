# -*- encoding : utf-8 -*-

include Card::Set::All::Permissions::Accounts

view :editor do |args|
  card.content = ''
  _final_phrase_type_editor args
end

view :raw do |args|
  '<em>encrypted</em>'
end

event :encrypt_password, :on=>:save, :after=>:process_subcards do
  salt = (left && left.salt)
  unless salt.present? or salt = Wagn::Env[:salt] # hack - fix with better ORM handling
    errors.add :password, 'need a valid salt'
  end
  if updates.for :content
    unless Wagn::Env[:no_password_encryptions] # hack for import - fix with api for ignoring events
      self.content = Account.encrypt content, salt
    end
  end
end

event :validate_password, :on=>:save, :before=>:approve do
  unless content.length > 3
    errors.add :password, 'must be at least 4 characters'
  end
end

event :validate_password_present, :on=>:update, :before=>:approve do
  abort :success if content.blank?
end

def ok_to_read
  is_own_account? ? true : super
end