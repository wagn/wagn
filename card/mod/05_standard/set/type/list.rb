
event :update_related_listed_by_card_on_update, :after=>:store, :on=>:save, :changed=>:name, :when=>proc {|c| c.junction? } do
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

event :update_related_listed_by_card_on_update, :after=>:store, :on=>:save, :changed=>:type, :when=>proc {|c| c.junction? } do
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

event :update_related_listed_by_card_on_update, :after=>:store, :on=>:save, :changed=>:content, :when=>proc {|c| c.junction? } do
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

event :update_related_listed_by_card_on_delete, :after=>:store, :on=>:delete, :when=>proc {|c| c.junction? } do
  update_listed_by_cache_for item_keys
end

def update_listed_by_cache_for item_keys
  type_key = left.type_card.key

  item_keys.each do |item_key|
    key = "#{item_key}+#{type_key}"
    if Card::Cache[Card::Set::Type::ListedBy].exist? key
      Card.fetch(key).update_cached_list
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
