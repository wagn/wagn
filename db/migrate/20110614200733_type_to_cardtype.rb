class TypeToCardtype < ActiveRecord::Migration
  def self.up
    rename_column :cards, :type, :typecode
    execute "update cards c join cardtypes ct on c.extension_id = ct.id set c.codename = ct.class_name where extension_type = 'Cardtype';"
    execute "update cards c join cardtypes ct on c.codename = ct.classname join cards cc on cc.extension_id = ct.id and cc.extension_type = 'Cardtype' set c.typecode = ct.class_name ;"

  def self.down
    rename_column :cards, :typecode, :type
  end
end
