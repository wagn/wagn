# -*- encoding : utf-8 -*-

class AddAceScript < Card::CoreMigration
  def up
    Card[:all].fetch(trait: :script).add_item! 'script: ace'

    Card.create! name: 'script: ace', codename: 'script_ace', type: 'JavaScript'
  end
end
