event :set_recaptcha_public_key, :finalize do
  Card.config.recaptcha_public_key = content
end
