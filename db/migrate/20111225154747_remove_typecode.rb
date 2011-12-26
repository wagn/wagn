class RemoveTypecode < ActiveRecord::Migration
  def up
    remove_column :cards, :typecode
  end

  def down
    add_column :cards, :typecode

    execute %{update cards as c set typecode = code.card_id
                from codename code
                where c.type_id = code.card_id}
  end
end
