# -*- encoding : utf-8 -*-

class CreateProsemirrorCard < Card::CoreMigration
  def up
    Card.create! name: 'script: prosemirror', type_id: Card::JavaScriptID,
                 codename: 'script_prosemirror'
  end
end
