# -*- encoding : utf-8 -*-

class AddAceScript < Wagn::CoreMigration
  def up
    all_script = Card.fetch "*all+*script"
    all_script.add_item "script: ace"
    all_script.save!
    Card.create! :name=>"script: ace",:codename=>"script_ace",:type=>"JavaScript"
    Card.create! :name=>"worker-coffee",:codename=>"worker_coffee",:type=>"JavaScript"
    Card.create! :name=>"worker-css",:codename=>"worker_css",:type=>"JavaScript"
    Card.create! :name=>"worker-html",:codename=>"worker_html",:type=>"JavaScript"
    Card.create! :name=>"worker-javascript",:codename=>"worker_javascript",:type=>"JavaScript"
    Card.create! :name=>"worker-json",:codename=>"worker_json",:type=>"JavaScript"
    Card.create! :name=>"worker-scss",:codename=>"worker_scss",:type=>"JavaScript"
    Card.create! :name=>"mode-coffee",:codename=>"mode_coffee",:type=>"JavaScript"
    Card.create! :name=>"mode-css",:codename=>"mode_css",:type=>"JavaScript"
    Card.create! :name=>"mode-html",:codename=>"mode_html",:type=>"JavaScript"
    Card.create! :name=>"mode-javascript",:codename=>"mode_javascript",:type=>"JavaScript"
    Card.create! :name=>"mode-json",:codename=>"mode_json",:type=>"JavaScript"
    Card.create! :name=>"theme-textmate",:codename=>"theme_textmate",:type=>"JavaScript"
  end
end
