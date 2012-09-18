class TableRename < ActiveRecord::Migration
  def up
    rename_table :wiki_references, :card_references
    rename_table :revisions, :card_revisions
  end

  def down
    rename_table :card_references, :wiki_references
    rename_table :card_revisions, :revisions
  end
end
