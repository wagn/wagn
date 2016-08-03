# -*- encoding : utf-8 -*-

class CreateProsemirrorCard < Card::CoreMigration
  def up
    Card.create! name: 'script: prosemirror', type_id: Card::JavaScriptID,
                 codename: 'script_prosemirror'
    Card.search(type_id: Card::PointerID,
                right: { codename: 'script' },
                link_to: 'script: slot').each do |card|
      card.add_item! 'script: prosemirror'
    end
  end
end
