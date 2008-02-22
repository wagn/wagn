class RevisionAndReferenceIndices < ActiveRecord::Migration
  def self.up 
    add_index "revisions", ["card_id"], :name => "revisions_card_id_index"
    add_index "wiki_references", ["referenced_card_id"], :name=>"wiki_references_referenced_card_id"
    add_index "wiki_references", ["referenced_name"], :name=>"wiki_references_referenced_name"    
    add_index "wiki_references", ["card_id"], :name=>"wiki_references_card_id"    
    add_index "roles_users", ["user_id"], :name=>"roles_users_user_id"
    add_index "roles_users", ["role_id"], :name=>"roles_users_role_id"
  end

  def self.down
  end
end
                                         