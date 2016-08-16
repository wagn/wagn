# -*- encoding : utf-8 -*-

class AddDebuggerSessionCard < Card::Migration::Core
  def up
    Card.create! name: "*debugger", type_code: :session, codename: "debugger",
                 subcards: {
                   "+*self+*options" => "[[on]]",
                   "+*self+*input" => "[[checkbox]]",
                   "+*self+*help" => "show more useful error pages" }
  end
end
