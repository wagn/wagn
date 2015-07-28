
format :rss do
  def raw_feed_items
    [card]
  end 
end

format :html do
  include AddHelp::HtmlFormat
end
