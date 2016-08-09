# -*- encoding : utf-8 -*-

class AddRecaptchaKeyAndAdminInfoCards < Card::CoreMigration
  def up
    create_recaptcha_settings
    Card::Cache.reset_all
    create_admin_cards
    update_machine_output
  end

  def create_admin_cards
    admin_only name: "*admin info",
               codename: "admin_info"
    admin_only name: "*google_analytics_key",
               codename: "google_analytics_key"

    codenames = %w(debugger recaptcha_settings)
    content =
      codenames.map do |cn|
        "[[#{Card[cn.to_sym].name}]]"
      end.join "\n"
    admin_only name: "*admin settings",
               codename: "admin_settings",
               type_id: Card::PointerID,
               content: content
    add_admin_info_to_home_card
  end

  def add_admin_info_to_home_card
    return unless (home = Card[Card[:home].content])
    new_content = home.content.prepend "{{*admin info|content}}\n"
    home.update_attributes! content: new_content
  end

  def create_recaptcha_settings
    admin_only name: "*recaptcha settings",
               codename: :recaptcha_settings, type_id: Card::PointerID,
               content: "[[+public key]]\n" \
                        "[[+private key]]\n" \
                        "[[+proxy]]"
    Card::Cache.reset_all
    %w(public_key private_key proxy).each do |name|
      Card.create!(
        name: "#{Card[:recaptcha_settings].name}+#{name.tr('_', ' ')}",
        codename: "recaptcha_#{name}"
      )
    end
  end

  def admin_only args
    create_or_update args.reverse_merge(type_id: Card::PhraseID)
    %w(*read *update *delete).each do |perm|
      create_or_update name: "#{args[:name]}+*self+#{perm}",
                       content: "[[Administrator]]"
    end
  end
end
