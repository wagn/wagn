include All::Permissions::Accounts

def ok_to_update
  if own_account? && !Auth.always_ok?
    deny_because you_cant("change the status of your own account")
  else
    super
  end
end
