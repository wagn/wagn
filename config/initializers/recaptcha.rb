# -*- encoding : utf-8 -*-
Recaptcha.configure do |config|
  config.public_key  = Wagn::Conf[:recaptcha_public_key]  || nil
  config.private_key = Wagn::Conf[:recaptcha_private_key] || nil
  config.proxy       = Wagn::Conf[:recaptcha_proxy] || nil
end
