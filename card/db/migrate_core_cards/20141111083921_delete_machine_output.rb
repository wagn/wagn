# -*- encoding : utf-8 -*-

class DeleteMachineOutput < Card::CoreMigration
  def up
    Card.search( :right => { :codename => 'machine_output' } ).each do |card|
      card.delete!
    end      
  end
end
