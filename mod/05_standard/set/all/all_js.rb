    
format :js do
  view :include_tag do |args|
    %{\n#{javascript_include_tag page_path(card.name) }\n }
  end
  
end