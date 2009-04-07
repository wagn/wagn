class CreateMultihostMappings < ActiveRecord::Migration
  def self.up
    if System.multihost
      execute "set search_path to public"
      create_table :multihost_mappings do |t|
        t.string :requested_host
        t.string :canonical_host
        t.string :wagn_name
        t.timestamps
      end
      add_index :multihost_mappings, :requested_host, :unique=>true
    end
  end

  def self.down        
    if System.multihost    
      drop_table :multihost_mappings
    end
  end
end
