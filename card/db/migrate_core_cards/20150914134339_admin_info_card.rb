# -*- encoding : utf-8 -*-

class AdminInfoCard < Card::CoreMigration
  def up
    create_admin_cards
    update_recaptcha_settings
    update_machine_output
  end

  def create_admin_cards
    Card.create! name: '*admin info',
                 codename: 'admin_info',
                 subcards: { '+*self+*read' => '[[Administrator]]' }

    codenames = %w(default_html_view debugger recaptcha_settings)
    content =
      codenames.map do |cn|
        "[[#{Card[cn.to_sym].name}]]"
      end.join "\n"
    Card.create! name: '*admin settings',
                 codename: 'admin_settings',
                 type_id: Card::PointerID, content: content,
                 subcards: { '+*self+*read' => '[[Administrator]]' }
  end

  def update_recaptcha_settings
    Card[:recaptcha_settings].update_attributes!(
      type_id: Card::PointerID,
      content: '[[+public key]]\n[[+private key]]\n[[+proxy]]'
    )

    ['public_key', 'private_key', 'proxy'].each do |name|
      card = Card["recaptcha_#{name}".to_sym]
      card.update_attributes!(
        name: "#{Card[:recaptcha_settings].name}+#{name.gsub('_', ' ')}"
      )
    end
    Card.fetch('*recaptcha settings+*self+*structure').delete
  end
end
