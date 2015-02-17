# -*- encoding : utf-8 -*-

class AddAceScript < Card::CoreMigration
  def up
    all_script = Card[:all].fetch :trait=>:script
    all_script.add_item "script: ace"
    all_script.save!
    
    Card.create! :name=>"script: ace",:codename=>"script_ace",:type=>"JavaScript"

  end
end
