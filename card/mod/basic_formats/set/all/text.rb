
format :text do
  view :core do
    HTMLEntities.new.decode strip_tags(super()).to_s
    # need this string method to get out of html_safe mode
  end
end
