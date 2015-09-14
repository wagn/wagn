format :html do

  view :closed do |args|
    args.merge! :body_class=>'closed-content'
    super args
  end

end
