class AddTypeId < ActiveRecord::Migration
  def up
    add_column :cards, :type_id, :integer
    add_column :cardtypes, :card_id, :integer
  end

  def down
    remove_column :cards, :type_id
    remove_column :cardtypes, :card_id
  end
end
