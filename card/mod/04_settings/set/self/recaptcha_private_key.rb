event :update_recaptcha_private_key, after: :store do
  Recaptcha.configure do |config|
    Cardio.config.recaptcha_private_key = raw_content
    config.private_key  = raw_content
  end
end

extend Card::Setting
setting_opts group: :config, position: 2, rule_type_editable: false
