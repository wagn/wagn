class Bootstrap
  class Component
    class Panel < Component
      add_div_method :panel, "panel panel-default"
      add_div_method :heading, "panel-heading"
      add_div_method :body, "panel-body"
    end
  end
end
