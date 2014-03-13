# -*- encoding : utf-8 -*-

include Card::Set::All::Permissions::Accounts

def ok_to_update
  if is_own_account? && !Account.always_ok?
    deny_because you_cant('change the status of your own account')
  else
    super
  end 
end