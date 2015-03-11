
view :editor do |args|
  text_area :content, :rows=>5, :class=>'card-content', :data_card_type_code=>card.type_code
end

view :closed_content do |args|
  ''
end

def clean_html?
  false
end

def diff_args
 {:format=>:raw}
end

format do
  def chunk_list
    :references
  end
end
