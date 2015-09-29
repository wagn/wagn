# My claim+sources (list)
# content:
# My source+claims (listed by)
#



event :validate_list_name, :before=>:validate, :on=>:save, :changed=>:name do
  if !junction? || !right || right.type_id != CardtypeID
    errors.add :name, "must have a cardtype name as right part"
  end
end

event :validate_list_item_type_change, :before=>:validate, :on=>:save, :changed=>:name do

  item_cards.each do |item_card|
    if item_card.type_cardname.key != item_type_name.key
      errors.add :name, "name conflicts with list items' type; delete content first"
    end
  end
end

event :validate_list_content, :before=>:validate, :on=>:save, :changed=>:content do
  item_cards.each do |item_card|
    if item_card.type_cardname.key != item_type_name.key
      errors.add :content, "#{item_card.name} has wrong cardtype; only cards of type #{cardname.right} are allowed"
    end
  end
end

event :update_related_listed_by_card_on_name_update, :after=>:store, :on=>:update, :changed=>:name do
  update_all_items
end

event :update_related_listed_by_card_on_type_update, :after=>:store, :on=>:update, :changed=>:type_id do
  update_all_items
end

event :update_related_listed_by_card_on_create, :after=>:store, :on=>:create do
  update_listed_by_cache_for item_keys
end


def update_all_items
  current_items = item_keys
  if db_content_was
    old_items = item_keys(:content=>db_content_was)
    update_listed_by_cache_for old_items
  end
  update_listed_by_cache_for current_items
end

event :update_related_listed_by_card_on_content_update, :after=>:store, :on=>:update, :changed=>:content do
  new_items = item_keys
  changed_items =
    if db_content_was
      old_items = item_keys(:content=>db_content_was)
      old_items + new_items - (old_items & new_items)
    else
      new_items
    end
  update_listed_by_cache_for changed_items
end


event :cache_type_key, :before=>:store, :on=>:delete, :when=>proc {|c| c.junction? } do
  @left_type_key = left.type_card.key

end

event :update_related_listed_by_card_on_delete, :after=>:store, :on=>:delete, :when=>proc {|c| c.junction? } do
  update_listed_by_cache_for item_keys, :type_key => @left_type_key
end

def update_listed_by_cache_for item_keys, args={}
  type_key = args[:type_key] || left.type_card.key

  item_keys.each do |item_key|
    key = "#{item_key}+#{type_key}"
    if Card::Cache[Card::Set::Type::ListedBy].exist? key
      if (card = Card.fetch(key))
        Card.fetch(key).update_cached_list
      else
        Card::Cache[Card::Set::Type::ListedBy].delete key
      end
    end
  end
end


include Pointer
format do
  include Pointer::Format
end
format :html do
  include Pointer::HtmlFormat
end
format :css do
  include Pointer::CssFormat
end
format :js do
  include Pointer::JsFormat
end
format :data do
  include Pointer::DataFormat
end

def item_type
  cardname.right
end

def item_type_name
  cardname.right_name
end

def item_type_card
  cardname.right
end

def item_type_id
  right.id
end