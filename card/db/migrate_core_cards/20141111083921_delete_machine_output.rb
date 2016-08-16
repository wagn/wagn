# -*- encoding : utf-8 -*-

class DeleteMachineOutput < Card::Migration::Core
  def up
    Card.search(right: { codename: "machine_output" }).each(&:delete!)
  end
end
