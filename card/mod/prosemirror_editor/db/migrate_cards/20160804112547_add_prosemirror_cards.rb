# -*- encoding : utf-8 -*-

class AddProsemirrorCards < Card::Migration
  PM_CONFIG = <<-JSON.strip_heredoc
                {
                  "menuBar": true,
                  "tooltipMenu": false
                }
              JSON
  def up
    ensure_card name: "*ProseMirror", type_id: Card::PlainTextID,
                codename: "prose_mirror",
                content: PM_CONFIG
    create_or_update(
      name: "*ProseMirror+*self+*help",
      content: "Configure [[http://prosemirror.net|ProseMirror]], "\
               "Wagn's default "\
               "[[http://en.wikipedia.org/wiki/Wysiwyg|wysiwyg]] editor. "\
               "[[http://wagn.org/ProseMirror|more]]"
    )
    ensure_card name: "script: prosemirror", type_id: Card::JavaScriptID,
                codename: "script_prosemirror"
    ensure_card name: "script: prosemirror config",
                type_id: Card::CoffeeScriptID,
                codename: "script_prosemirror_config"
  end
end
