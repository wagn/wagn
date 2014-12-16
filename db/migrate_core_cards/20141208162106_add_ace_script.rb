# -*- encoding : utf-8 -*-

class AddAceScript < Wagn::CoreMigration
  def up
    all_script = Card.fetch "*all+*script"
    all_script.add_item "script: ace"
    all_script.save!
    js_path = "WagnGem:mod/03_machines/lib/javascript/ace"
    Card.create! :name=>"FileContent",:type=>"Cardtype",:codename=>"file_content"
    Card.create! :name=>"FileContent+*type+*create",:type=>"Pointer",:content=>"[[Administrator]]"
    Card.create! :name=>"FileContent+*type+*update",:type=>"Pointer",:content=>"[[Administrator]]"
    Card.create! :name=>"FileContent+*type+*delete",:type=>"Pointer",:content=>"[[Administrator]]"
      
    Card.create! :name=>"script: ace",:type=>"FileContent",:content=>"#{js_path}/ace.js"

  end
end
