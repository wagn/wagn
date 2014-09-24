def clean_html?
  false
end

format :email do
  view :missing        do |args| '' end
  view :closed_missing do |args| '' end
  
  def strip_html string
    string.gsub(/<\/?[^>]*>/, "")
  end
end