format :html do
  def bs_panel opts={}, &block
    Bootstrap::Panel.render self, opts, &block
  end
end
