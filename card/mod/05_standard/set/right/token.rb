include All::Permissions::Accounts

DURATIONS = "second|minute|hour|day|week|month|year".freeze

card_accessor :expiration

view :raw do
  "Private data"
end

def validate! token
  error =
    case
    when !real?           then [:token_not_found, "no token found"]
    when expired?         then [:token_expired, "expired token"]
    when content != token then [:incorrect_token, "token mismatch"]
    end
  errors.add *error if error
end

def expired?
  !permanent? && updated_at <= term.ago
end

def permanent?
  term == "permanent"
end

def used!
  Auth.as_bot { delete! } unless permanent?
end

def term
  @term ||=
    if expiration.present?
      term_from_string expiration
    else
      Card.config.token_expiry
    end
end

def term_from_string string
  string.strip!
  return "permanent" if string == "none"
  re_match = /^(\d+)[\.\s]*(#{DURATIONS})s?$/.match(string)
  number, unit = re_match.captures if re_match
  if unit
    number.to_i.send unit
  else
    raise Card::Oops, "illegal expiration value (eg '2 days')"
  end
end
