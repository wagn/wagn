class AddCardtypeConstraint < ActiveRecord::Migration
  def self.up
    execute %{ alter table cards alter column type set not null }
    add_index :cardtypes, ["class_name"], :name=>"cardtypes_class_name_uniq", :unique=>true
    add_foreign_key :cards, :type, :cardtypes, 'class_name'
  end

  def self.down
    execute %{ alter table cards alter column type drop not null }
    drop_foreign_key :cards, :type, :cardtypes 
    remove_index  :cardtypes, :name=>"cardtypes_class_name_uniq"  
  end                        
end                                                                                                      
