# -*- encoding : utf-8 -*-
def load_config_from_card codename
  # the seed task runs initializers so we have to check
  # if the cards table is ready before we use it here
  if ActiveRecord::Base.connection.table_exists? 'cards'
    ((ca = Card[codename]) && ca.raw_content.present? && ca.raw_content) ||
    Card::Auth.DEFAULT_RECAPTCHA_SETTINGS[codename] ||
    nil
  end
end

Recaptcha.configure do |config|
  Cardio.config.recaptcha_public_key  ||= load_config_from_card( :recaptcha_public_key )
  Cardio.config.recaptcha_private_key ||= load_config_from_card( :recaptcha_private_key )
  Cardio.config.recaptcha_proxy       ||= load_config_from_card( :recaptcha_proxy )
  config.public_key  = Cardio.config.recaptcha_public_key
  config.private_key = Cardio.config.recaptcha_private_key
  config.proxy       = Cardio.config.recaptcha_proxy
end
