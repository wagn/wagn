# -*- encoding : utf-8 -*-

class TweakRecaptchaSettingCards < Card::Migration::Core
  def up
    ensure_card name: "*recaptcha settings", type_id: Card::BasicID
    ensure_card name: "*recaptcha settings+*self+*structure",
                content: <<-STRING
{{+public key}}
{{+private key}}
{{+proxy}}
    STRING
    %w(public_key private_key proxy).each do |name|
      ensure_card name: "#{Card[:recaptcha_settings].name}+#{name.tr('_', ' ')}",
                  type_id: Card::PhraseID
    end
  end
end
