# -*- encoding : utf-8 -*-

class AddNotificationEventCard < Card::Migration::Core
  def up
    ensure_card "Notification template", codename: "notification_template",
                type_id: Card::CardtypeID
    ensure_trait "*message", "message", default: { type_id: Card::PhraseID }
    ensure_trait "*disappear", "disappear", default: { type_id: Card::ToggleID }
    ensure_trait "*contextual class", "contextual_class",
                 default: { type_id: Card::PointerID },
                 input: "radio",
                 options: %w(success info warning danger)

    [:create, :update, :delete].each do |action|
      update ["on_#{action}".to_sym, :right, :help],
             content: "Configure events to be executed when card id #{action}d"
    end


  end
end
