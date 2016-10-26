format :html do
  def bs_panel opts={}, &block
    BootstrapPanel.render self, opts, &block
  end

  class BootstrapPanel < BootstrapBuilder
    add_div_method :panel, "panel panel-default"
    add_div_method :heading, "panel-heading"
    add_div_method :body, "panel-body"
  end
end
