# -*- encoding : utf-8 -*-

class UpdateLayout < Card::Migration::Core
  def up
    binding.pry
    merge_cards ["*header", "*main_menu"]
  end
end