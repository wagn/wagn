
module Wagn
  module Set::All::Xml
    include Sets

    format :xml

    define_view(:layout) do |args|
      if @main_content = args.delete( :main_content )
        @card = Card.fetch '*placeholder',:new=>{}, :skip_defaults=>true
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
      c = _render_core(args)
      c = "<span class=\"faint\">--</span>" if c.size < 10 && strip_tags(c).blank?
      wrap(:content, args) { wrap_content(:content) { c } }
    end

    define_view(:content) do |args|
      @state = :view
      self.wrap(:content, args) { _render_core(args) }
    end

    define_view(:open) do |args|
      @state = :view
      self.wrap(:open, args) { _render_core(args) }
    end

    define_view(:closed) do |args|
      @state = :line
      self.wrap(:closed, args) { _render_line(args) }
    end

=begin
    define_view(:setting) do |args|
      self.wrap(:content, args) { render_partial('views/setting') }
    end
=end

    [ :deny_view, :edit_auto, :too_slow, :too_deep, :open_missing, :closed_missing, :setting_missing, :missing ].each do |view|
      define_view(view) do |args|
         %{<no_card status="#{view.to_s.gsub('_',' ')}">#{card.name}</no_card>}
      end
    end

   end
end
