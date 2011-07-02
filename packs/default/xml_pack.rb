require 'wagn/renderer/xml'

class Wagn::Renderer::Xml
  define_view(:layout) do |args|
    if @main_content = args.delete(:main_content)
      @card = Card.fetch_or_new('*placeholder',{},:skip_defaults=>true)
    else
      @main_card = card
    end  

    layout_content = get_layout_content(args)
    
    args[:context] = self.context = "layout_0"
    args[:action]="view"  
    args[:relative_content] = args[:params] = params 
    
    process_content(layout_content, args)
  end

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
    wrap(args) { _render_naked(args) }
  end

  define_view(:closed) do |args|
    @state = :line
    self.requested_view = args[:action] = 'closed'
    wrap(args) { _render_line(args) }
  end

=begin
  define_view(:setting) do |args|
    self.requested_view = args[:action] = 'content'
    wrap( args) { render_partial('views/setting') }
  end
=end

  [ :deny_view, :edit_auto, :too_slow, :too_deep, :open_missing, :closed_missing, :setting_missing ].each do |view|
    define_view(view) do |args|
       %{<no_card status="#{view.to_s.gsub('_',' ')}">#{card.name}</no_card>}
    end
  end

end
