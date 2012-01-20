class AddTypeId < ActiveRecord::Migration
  def up
    dbtype = ActiveRecord::Base.configurations[Rails.env]['adapter']
    add_column :cards, :type_id, :integer
    add_column :cardtypes, :card_id, :integer

    if dbtype.to_s == 'mysql'
      execute %{update cardtypes ct, cards c
                   set ct.card_id = c.id
                 where ct.id = c.extension_id and c.extension_type='Cardtype'}

      execute %{update cards c, cardtypes ct
                   set c.type_id = ct.card_id
                 where c.typecode = ct.class_name }
    else
      execute %{update cardtypes ct set card_id = c.id from cards c
                 where ct.id = c.extension_id and c.extension_type='Cardtype'}

      execute %{update cards c set type_id = ct.card_id from cardtypes ct
                 where c.typecode = ct.class_name }
    end
  end

  def down
    remove_column :cards, :type_id
    remove_column :cardtypes, :card_id
  end
end
