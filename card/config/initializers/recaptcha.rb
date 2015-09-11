# -*- encoding : utf-8 -*-
Recaptcha.configure do |config|
  config.public_key  = Cardio.config.recaptcha_public_key  || nil
  config.private_key = Cardio.config.recaptcha_private_key || nil
  config.proxy       = Cardio.config.recaptcha_proxy       || nil
  config.api_version = 'v1' if config.respond_to?(:api_version=)
end
