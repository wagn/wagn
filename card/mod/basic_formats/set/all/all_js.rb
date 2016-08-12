
format :js do
  view :include_tag do |_args|
    %(\n#{javascript_include_tag page_path(card.cardname)}\n )
  end
end
