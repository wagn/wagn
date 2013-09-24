# -*- encoding : utf-8 -*-

include Card::Set::Type::Pointer

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
  Card::Set::Right::Style.delete_style_files
end

