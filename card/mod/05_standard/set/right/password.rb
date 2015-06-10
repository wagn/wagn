
include All::Permissions::Accounts

view :editor do |args|
  card.content = ''
  autocomplete = (@parent && @parent.card.name=='*signin+*account') ? 'on' : 'off' #hack
  password_field :content, :class=>'card-content', :autocomplete=>autocomplete
end

view :raw do |args|
  '<em>encrypted</em>'
end

event :encrypt_password, :on=>:save, :after=>:process_subcards do
  salt = (left && left.salt)
  unless salt.present? or salt = Card::Env[:salt] # hack - fix with better ORM handling
    #errors.add :password, 'need a valid salt'
    # turns out we have a lot of existing account without a salt.  not sure when that broke??
  end
  if db_content_changed?
    unless Card::Env[:no_password_encryptions] # hack for import - fix with api for ignoring events
      self.content = Auth.encrypt content, salt
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
