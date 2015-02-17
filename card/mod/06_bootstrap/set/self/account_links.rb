
format :html do

  view :raw do |args|    
    content_tag :ul, :class=>"nav navbar-nav navbar-right" do
      account_links.map do |al|
        content_tag :li, al
      end.join "\n"
    end
  end

end
