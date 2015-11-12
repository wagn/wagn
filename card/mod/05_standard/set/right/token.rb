include All::Permissions::Accounts

view :raw do |args|
  'Private data'
end

def validate! token
  error =
    case
    when !real?           then [:token_not_found, 'no token found']
    when expired?         then [:token_expired, 'expired token']
    when content != token then [:incorrect_token, 'token mismatch']
    end
  errors.add *error if error
end

def expired?
  !permanent? && updated_at <= term.ago
end

def permanent?
  false
end

def used!
  Auth.as_bot { delete! } unless permanent?
end

def term
  Card.config.token_expiry
end
