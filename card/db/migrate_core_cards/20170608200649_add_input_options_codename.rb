# -*- encoding : utf-8 -*-

class AddInputOptionsCodename < Card::Migration::Core
  def up
    ensure_card [:input, :right, :options],
                codename: "input_options"
  end
end
