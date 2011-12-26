class AddTypeId < ActiveRecord::Migration
  def up
    add_column :cards, :type_id, :integer

    execute %{update cards as c set type_id = code.id
                from cardtypes ct, cards code
                where ct.id = code.extension_id
                  and code.extension_type='Cardtype'
                  and c.typecode=ct.class_name
    }
  end

  def down
    remove_column :cards, :type_id
  end
end
