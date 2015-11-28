event :update_recaptcha_proxy, after: :store do
  Recaptcha.configure do |config|
    Cardio.config.recaptcha_proxy = raw_content
    config.proxy  = raw_content
  end
end

extend Card::Setting
setting_opts group: :config, position: 3, rule_type_editable: false
