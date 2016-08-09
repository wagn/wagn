# -*- encoding : utf-8 -*-

# card config overrides application.rb config overrides default
def load_recaptcha_config setting
  setting = "recaptcha_#{setting}".to_sym
  Cardio.config.send("#{setting}=",
                     load_recaptcha_card_config(setting) || # card content
                     Cardio.config.send(setting) || # application.rb
                     Card::Auth::DEFAULT_RECAPTCHA_SETTINGS[setting])
end

def card_table_ready?
  # FIXME: this test should be more generally usable
  ActiveRecord::Base.connection.table_exists?("cards") &&
    Card.ancestors.include?(ActiveRecord::Base)
end

# use if card with value is present
def load_recaptcha_card_config setting
  card = Card.find_by_codename setting
  card && card.db_content.present? && card.db_content
end

Recaptcha.configure do |config|
  # the seed task runs initializers so we have to check
  # if the cards table is ready before we use it here
  if card_table_ready?
    [:public_key, :private_key, :proxy].each do |setting|
      config.send "#{setting}=", load_recaptcha_config(setting)
    end
  end
end
