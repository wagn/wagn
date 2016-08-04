
format :text do
  view :core do |args|
    HTMLEntities.new.decode strip_tags(super args).to_s # need this string method to get out of html_safe mode
  end
end
