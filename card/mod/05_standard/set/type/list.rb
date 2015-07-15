

event :update_related_listed_by_card_on_update, :after=>:store, :on=>:save, :when=>proc {|c| c.junction? } do
  old_items = item_keys(:content=>db_content_was)
  new_items = item_keys
  changed_items = old_items + new_items - (old_items & new_items)

  changed_items.each do |item_key|
    update_listed_by_cache_for item_key
  end
end

event :update_related_listed_by_card_on_delete, :after=>:store, :on=>:delete, :when=>proc {|c| c.junction? } do
  item_keys.each do |item_key|
    update_listed_by_cache_for item_key
  end
end

def update_listed_by_cache_for item_key
  key = "#{item_key}+#{right_id}"
  if Card::Cache[Card::Set::Type::ListedBy].exist? key
    Card.fetch(key).update_cached_list
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
