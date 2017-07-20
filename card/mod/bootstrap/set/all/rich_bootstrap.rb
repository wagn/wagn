format :html do
  view :closed do
    class_up "d0-card-body", "closed-content"
    super()
  end

  include Bootstrapper
end
