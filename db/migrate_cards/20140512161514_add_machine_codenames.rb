# -*- encoding : utf-8 -*-

class AddMachineCodenames < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      Card.create! :name=>'*machine output', :codename=>:machine_output, :type_id=>Card::FileID
      Card.create! :name=>'*machine input', :codename=>:machine_input, :type_id=>Card::PointerID
    end
  end
end

