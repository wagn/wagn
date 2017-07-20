class Bootstrap
  class Component
    class Panel < Component
      add_div_method :panel, "card"
      add_div_method :heading, "card-header"
      add_div_method :body, "card-block"
    end
  end
end
