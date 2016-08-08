# add new indeces for datetime and ref_type fields
class NewIndeces < ActiveRecord::Migration
  def change
    add_index "card_references", ["ref_type"],
              name: "card_references_ref_type_index" # using: :btree
    add_index "cards", ["created_at"], name: "cards_created_at_index"
    add_index "cards", ["updated_at"], name: "cards_updated_at_index"
    add_index "card_acts", ["acted_at"], name: "acts_acted_at_index"
  end
end
