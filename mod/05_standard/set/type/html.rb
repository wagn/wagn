
view :editor do |args|
  form.text_area :content, :rows=>5, :class=>'card-content'
end

view :closed_content do |args|
  ''
end

def clean_html?
  false
end

def chunk_list
  :references
end


format :html do
  view :content_changes do |args|
    super(args.merge(:diff_opts=>{:format=>:raw}))
  end
end