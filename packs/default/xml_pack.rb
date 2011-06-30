require 'wagn/renderer/xml'

class Wagn::Renderer::Xml
  define_view(:show) do
    self.render_content #???
  end
  
  define_view(:content) do |args|
    @state = :view
    self.requested_view = args[:action] = 'content'
    wrap(args) { _render_naked(args) }
  end

  define_view(:open) do |args|
    @state = :view
    self.requested_view = 'open'
    wrap(args) { render_partial('views/open') } +
    open_close_js(:to_open)
  end

  define_view(:closed) do |args|
    @state = :line
    self.requested_view = args[:action] = 'closed'
    wrap(args) { render_partial('views/closed') } + 
    open_close_js(:to_closed)
  end

  define_view(:setting) do |args|
    self.requested_view = args[:action] = 'content'
    wrap( args) { render_partial('views/setting') }
  end

  [ :deny_view, :edit_auto, :too_slow, :too_deep, :open_missing, :closed_missing, :setting_missing ].each do |view|
    define_view(view) do |args|
       %{<no_card status="#{view}">#{card.name}</no_card>}
    end
  end


end
