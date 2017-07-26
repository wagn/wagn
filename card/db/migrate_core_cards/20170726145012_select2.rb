# -*- encoding : utf-8 -*-

class Select2 < Card::Migration
  def up
    add_script "select2",
                type_id: Card::JavaScriptID,
                to: "*all+*script"

    add_style"select2",
             type_id: Card::CssID,
                  to: "*all+*style"

    add_style"select2 bootstrap",
                 type_id: Card::ScssID,
                      to: "*all+*style"

    add_script "load select2",
               to: "*all+*script"
  end
end
