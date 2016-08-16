# -*- encoding : utf-8 -*-

class AddAceCards < Card::Migration
  ACE_CONFIG = <<-JSON.strip_heredoc
                 {
                   "default": {
                     "showGutter": true,
                     "theme": "ace/theme/github",
                     "printMargin": false,
                     "tabSize": 2,
                     "useSoftTabs": true,
                     "maxLines": 30
                   }
                 }
               JSON
  def up
    ensure_card name: "*Ace", type_id: Card::PlainTextID,
                codename: "ace", content: ACE_CONFIG
    create_or_update(
      name: "*Ace+*self+*help",
      content: "Configure [[https://ace.c9.io|ace]], "\
               "Wagn's default code editor. [[http://wagn.org/ace|more]]"
    )
    ensure_card name: "script: ace", type_id: Card::JavaScriptID,
                codename: "script_ace"
    ensure_card name: "script: ace config",
                type_id: Card::CoffeeScriptID,
                codename: "script_ace_config"
  end
end
