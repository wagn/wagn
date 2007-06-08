class FixGraveyardContentType < ActiveRecord::Migration
  def self.up
    change_column :graveyard, :content, :text
  end

  def self.down
    change_column :graveyard, :content, :string
  end
end
