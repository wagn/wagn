# -*- encoding : utf-8 -*-
Recaptcha.configure do |config|
  config.public_key  = Card.config.recaptcha_public_key  || nil
  config.private_key = Card.config.recaptcha_private_key || nil
  config.proxy       = Card.config.recaptcha_proxy       || nil
end
