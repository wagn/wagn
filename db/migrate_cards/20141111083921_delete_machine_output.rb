# -*- encoding : utf-8 -*-

class DeleteMachineOutput < Wagn::Migration
  def up
    Card.search( :right => { :codename => 'machine_output' } ).each do |card|
      card.delete!
    end      
  end
end
