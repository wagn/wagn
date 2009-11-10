class AddCodenameToCards < ActiveRecord::Migration
  def self.up
    add_column :cards, :codename, :string
  end

  def self.down
    remove_column :cards, :codename
  end
end
