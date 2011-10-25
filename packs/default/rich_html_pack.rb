class Wagn::Renderer::RichHtml
  define_view(:show) do |args|
    if ajax_call?
      home_view = params[:home_view]=='closed' ? :open : params[:home_view]
      view = params[:view] || home_view || :open
      self.render(view , :add_javascript=>true)
    else
      self.render_layout
    end
  end
  
  define_view(:layout) do |args|
    if @main_content = args.delete(:main_content)
      @card = Card.fetch_or_new('*placeholder')
    else
      @main_card = card
    end  

    layout_content = get_layout_content(args)
    
    args[:context] = self.context = "layout_0"
    args[:action]="view"  
    args[:relative_content] = args[:params] = params 
    
    process_content(layout_content, args)
  end
  

  define_view(:content) do |args|
    @state = :view
    self.requested_view = args[:action] = 'content'
    c = _render_naked(args)
    c = "<span class=\"faint\">--</span>" if c.size < 10 && strip_tags(c).blank?
    wrap(args) { raw wrap_content(c) }
  end

  define_view(:titled) do |args|
    self.requested_view = 'titled'
    args[:action] = 'content'
    wrap(args) do
      content_tag( :h1, fancy_title(card.name) ) + 
      wrap_content(_render_naked(args))
    end
  end

  define_view(:new) do |args|
    wrap(args) { render_partial('views/new') }
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

  define_view(:edit) do |args|
    @state=:edit
#    warn "card #{card.name} at view(:edit) = #{card.inspect}\ncard.content_template = #{card.content_template.inspect}"
    card.content_template ?  _render_multi_edit(args) : content_field(form)
  end


  define_view(:editor) do |args|
    eid, raw_id = context, context+'-raw-content'
    form.hidden_field( :content, :id=>"#{eid}-hidden-content" ) +
    text_area_tag( :content_to_replace, card.content, :rows=>3, :id=>"#{eid}-tinymce" ) +
    editor_hooks( :setup=> %{setTimeout((function(){
  tinyMCE.init({mode: "exact",elements: "#{eid}-tinymce",#{System.setting('*tiny mce') || ''}})
  tinyMCE.execInstanceCommand( '#{eid}-tinymce', 'mceFocus' );
}),50); 
  }, 
      :save=> %{t = tinyMCE.getInstanceById( '#{eid}-tinymce' ); $('#{eid}-hidden-content').value = t.getContent(); return true;})
  end

  define_view(:multi_edit) do |args|
    @state=:edit
    args[:add_javascript]=true #necessary?
    @form = form_for_multi
    hidden_field_tag(:multi_edit, true) + _render_naked(args)
  end

  define_view(:change) do |args|
    self.requested_view = args[:action] = 'content'
    wrap(args) { render_partial('views/change') }
  end

###---(  EDIT VIEWS )
  define_view(:edit_in_form) do |args|
    eform = form_for_multi
    %{
<div class="edit-area in-multi RIGHT-#{ card.cardname.tag_name.to_cardname.css_name }">
  <div class="label-in-multi">
    <span class="title">
      #{ link_to_page(fancy_title(self.showname || card), (card.new_card? ? card.cardname.tag_name : card.name)) }
    </span>
  </div>     
  
  <div class="field-in-multi">
    #{ self.content_field( eform, :nested=>true ) }
    #{ card.new_card? ? eform.hidden_field(:typecode) : '' }
  </div>
  #{if inst = (card.new_card? ? card.setting_card('add help', 'edit help') : card.setting_card('edit help'))
    ss = self.subrenderer(inst); ss.state= :view
    %{<div class="instruction">#{ ss.render :naked }</div>}
  end}
  <div style="clear:both"></div>
</div>
    }
  end
end
