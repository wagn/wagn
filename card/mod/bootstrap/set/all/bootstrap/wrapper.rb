format :html do
  def frame
    class_up "card-header", "panel-heading"
    class_up "card-header-title", "panel-title"
    class_up "card-body", "panel-body"
    super
  end

  def standard_frame slot=true
    class_up "card-frame", "panel panel-default"
    super
  end
end
