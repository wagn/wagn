format :html do
  view :closed do |args|
    args[:body_class] = "closed-content"
    super args
  end
end
