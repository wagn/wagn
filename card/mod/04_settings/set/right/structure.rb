
format :rss do
  def raw_feed_items args
    [card]
  end
end

format :html do
  include AddHelp::HtmlFormat

  view :core do |args|
    render_raw args
  end

end
