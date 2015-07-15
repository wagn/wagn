def raw_content
  Card::Cache[Card::Set::Type::ListedBy].fetch(cache_key) do
    listed_by.map do |item|
      "[[%s]]" % item
    end
  end
end

def listed_by
  Card.search(:type=>:list, :right_id=>item_type_id, :refer_to=>name,:return=>:name)
end

def cache_key
  "#{key}+#{item_type_id}"
end

def item_type_id
  item_type_id = right.try :id
end

def update_cached_list
  Card::Cache[Card::Set::Type::ListedBy].write(cache_key) do
    listed_by.map do |item|
      "[[%s]]" % item
    end
  end
end



# def add_item name
#   unless include_item? name
#     cached_content_card.add_item name
#     cached_count_card.content = cached_count + 1
#   end
# end
#
# def add_item! name
#   unless include_item? name
#     ccc = cached_content_card
#     ccc.add_item name
#     ccc.save!
#     ccc = cached_count_card
#     ccc.content = cached_count + 1
#     ccc.save!
#   end
# end
#
# def drop_item name
#   if include_item? name
#     key = name.to_name.key
#     new_names = cached_content_card.item_names.reject{ |n| n.to_name.key == key }
#     cached_content_card.content = new_names.empty? ? '' : "[[#{new_names * "]]\n[["}]]"
#     cached_count_card.content = cached_count - 1
#   end
# end
# def drop_item! name
#   if include_item? name
#     key = name.to_name.key
#     ccc = cached_content_card
#     new_names = ccc.item_names.reject{ |n| n.to_name.key == key }
#     ccc.content = new_names.empty? ? '' : "[[#{new_names * "]]\n[["}]]"
#     ccc.save!
#     ccc = cached_count_card
#     ccc.content = cached_count - 1
#     ccc.save!
#   end
# end

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


