# -*- encoding : utf-8 -*-

class DeleteMachineOutput < Wagn::CoreMigration
  def up
    Card.search( :right => { :codename => 'machine_output' } ).each do |card|
      card.delete!
    end      
  end
end
