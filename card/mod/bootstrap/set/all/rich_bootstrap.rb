format :html do
  def bootstrap
    @bootstrap ||= ::Bootstrap.new(self)
  end

  view :closed do
    class_up "card-body", "closed-content"
    super()
  end

  def bs *args, &block
    bootstrap.render *args, &block
  end
end
