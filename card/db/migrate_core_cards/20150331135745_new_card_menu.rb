# -*- encoding : utf-8 -*-

class NewCardMenu < Card::CoreMigration
  def up
    Card.create! :name=>'follow dialog', :codename=>'follow_dialog'
  end
end
