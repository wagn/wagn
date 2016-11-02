event :set_recaptcha_private_key, :finalize do
  Card.config.recaptcha_public_key = content
end
