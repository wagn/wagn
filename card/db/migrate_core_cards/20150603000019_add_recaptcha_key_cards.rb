# -*- encoding : utf-8 -*-

class AddRecaptchaKeyCards < Card::CoreMigration
  def up
    admin_only name: '*recaptcha public key',
               codename: :recaptcha_public_key
    admin_only name: '*recaptcha private key',
               codename: :recaptcha_private_key
    admin_only name: '*recaptcha proxy',
               codename: :recaptcha_proxy
    admin_only name: '*recaptcha settings',
               codename: :recaptcha_settings, type_id: Card::BasicID,
               subcards: { '+*self+*structure' => {
                 content: "{{*recaptcha public key|titled}}\n" \
                          "{{*recaptcha private key|titled}}\n" \
                          '{{*recaptcha proxy|titled}}'
               } }
  end

  def admin_only args
    shared_args = { type_id: Card::PhraseID,
                    subcards: {
                      '+*self+*read' => { content: '[[Administrator]]' },
                      '+*self+*update' => { content: '[[Administrator]]' },
                      '+*self+*delete' => { content: '[[Administrator]]' },
                    }
                  }
    Card.create! shared_args.merge(args)
  end
end
