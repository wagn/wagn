include All::Permissions::Accounts

view :raw do |args|
  "Private data"
end

def validate! token
  errors.add :incorrect_token, 'token mismatch' if content != token
  errors.add :token_expired,   'expired token'  if expired?
end

def expired?
  !permanent? && updated_at <= term.ago
end

def permanent?
  false
end

def used!
  Auth.as_bot{ delete! } unless permanent?
end

def term
  Card.config.token_expiry
end
