event :set_recaptcha_proxy, :finalize do
  Card.config.recaptcha_proxy = content
end
