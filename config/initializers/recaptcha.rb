# -*- encoding : utf-8 -*-
Recaptcha.configure do |config|
  config.public_key  = Wagn.config.recaptcha_public_key  || nil
  config.private_key = Wagn.config.recaptcha_private_key || nil
  config.proxy       = Wagn.config.recaptcha_proxy       || nil
end
