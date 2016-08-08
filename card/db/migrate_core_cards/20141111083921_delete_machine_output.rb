# -*- encoding : utf-8 -*-

class DeleteMachineOutput < Card::CoreMigration
  def up
    Card.search(right: { codename: "machine_output" }).each(&:delete!)
  end
end
