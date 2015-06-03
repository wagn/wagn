event :update_recaptcha_public_key, :after=>:store do
  Recaptcha.configure do |config|
    Cardio.config.recaptcha_public_key = raw_content
    config.public_key  = raw_content
  end
end

extend Card::Setting
setting_opts :group=> :config, :position=>1, :rule_type_editable=>false