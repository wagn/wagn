format :html do
  def frame
    class_up "card-header", "panel-heading"
    class_up "card-header-title", "panel-title"
    class_up "card-body", "panel-body"
    super
  end

  def standard_frame
    class_up "card-frame", "panel panel-#{panel_state}"
    super
  end

  def panel_state
    "default"
  end
end
