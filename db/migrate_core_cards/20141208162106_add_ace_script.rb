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
    Card.create! :name=>"worker-coffee",:type=>"FileContent",:content=>"#{js_path}/worker-coffee.js"
    Card.create! :name=>"worker-css",:type=>"FileContent",:content=>"#{js_path}/worker-css.js"
    Card.create! :name=>"worker-html",:type=>"FileContent",:content=>"#{js_path}/worker-html.js"
    Card.create! :name=>"worker-javascript",:type=>"FileContent",:content=>"#{js_path}/worker-javascript.js"
    Card.create! :name=>"worker-json",:type=>"FileContent",:content=>"#{js_path}/worker-json.js"
    Card.create! :name=>"worker-scss",:type=>"FileContent",:content=>"#{js_path}/worker-scss.js"
    Card.create! :name=>"mode-coffee",:type=>"FileContent",:content=>"#{js_path}/mode-coffee.js"
    Card.create! :name=>"mode-css",:type=>"FileContent",:content=>"#{js_path}/mode-css.js"
    Card.create! :name=>"mode-html",:type=>"FileContent",:content=>"#{js_path}/mode-html.js"
    Card.create! :name=>"mode-javascript",:type=>"FileContent",:content=>"#{js_path}/mode-javascript.js"
    Card.create! :name=>"mode-json",:type=>"FileContent",:content=>"#{js_path}/mode-json.js"
    Card.create! :name=>"theme-textmate",:type=>"FileContent",:content=>"#{js_path}/theme-textmate.js"
  end
end
