
include Pointer

view :core, :type=>:pointer

format :html do
  view :closed_content, :type=>:pointer
  view :core,           :type=>:pointer
  view :editor,         :type=>:pointer
  view :list,           :type=>:pointer
  view :checkbox,       :type=>:pointer
  view :multiselect,    :type=>:pointer
  view :radio,          :type=>:pointer
  view :select,         :type=>:pointer  
end

format :css do
  view :content, :type=>:pointer
  view :core,    :type=>:pointer
end


event :reset_style_for_skin, :after=>:store do
  Right::Style.delete_style_files
end

def style_fingerprint
  item_cards.map do |item|
    item.respond_to?( :style_fingerprint ) ? item.style_fingerprint : item.current_revision_id.to_s
  end.join '-'
end