class Card
  class Format
    class HtmlFormat
      module Bootstrap
        class Panel < BootstrapBuilder
          add_div_method :panel, "panel panel-default"
          add_div_method :heading, "panel-heading"
          add_div_method :body, "panel-body"
        end
      end
    end
  end
end
