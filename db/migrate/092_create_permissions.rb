class CreatePermissions < ActiveRecord::Migration
  def self.up
    begin
      drop_table :permissions
    rescue
    end

    create_table :permissions do |t|
      t.column 'card_id', :integer
      t.column 'task', :string
      t.column 'party_type', :string
      t.column 'party_id', :integer
    end
  end

  def self.down
    drop_table :permissions
  end
end
