# -*- encoding : utf-8 -*-
Recaptcha.configure do |config|
  config.public_key  = CardRailtie.config.recaptcha_public_key  || nil
  config.private_key = CardRailtie.config.recaptcha_private_key || nil
  config.proxy       = CardRailtie.config.recaptcha_proxy       || nil
end
