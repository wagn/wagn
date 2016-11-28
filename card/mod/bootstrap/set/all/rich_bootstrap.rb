format :html do
  view :closed do
    class_up "card-body", "closed-content"
    super()
  end

  include Bootstrapper
end
