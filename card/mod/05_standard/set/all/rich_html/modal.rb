format :html do




  view :modal_link do |args|
    args[:html_args] ||= {}
    args[:html_args].merge!('data-target'=>"#modal-#{card.cardname.safe_key}", 'data-toggle'=>'modal')
    link_to(args[:text] || _render_title(args), path(:layout=>:modal), args[:html_args])
  end

  view :modal_slot do |args|
    wrap_with(:div, :class=>'modal fade', :role=>'dialog', :id=>"modal-#{card.cardname.safe_key}") do
      wrap_with(:div, :class=>'modal-dialog') do
        content_tag :div, :class=>'modal-content' do
          ''
        end
      end
    end
  end


  view :modal_menu do |args|
    popout_params = {}
    popout_params[:view] = params[:view] if params[:view]
    # we probably want to pass on a lot more params than just view, but not all of them
    # (eg we don't want layout, id, controller...)
    wrap_with :div, :class=>'modal-menu' do
      [
        link_to( glyphicon('remove'), '', :class=>'close-modal pull-right close', 'data-dismiss'=>'modal'),
        link_to( glyphicon('new-window'), popout_params, :class=>'pop-out-modal pull-right close ' )
      ]
    end
  end

=begin
  def default_modal_content_args args
    args[:buttons] ||= button_tag 'Close', 'data-dismiss'=>'modal'
  end

  view :modal_link_and_dialog do |args|
    _render_modal_link(args) + _render_modal(args)
  end



  # use modal_content for ajax calls to fill a modal_slot with content
  view :modal_content do |args|
    output [
      wrap_with( :div, _render_modal_header(args), :class=>'modal-header' ),
      wrap_with( :div, _render_modal_body(args),   :class=>'modal-body' ),
      wrap_with( :div, _render_modal_footer(args), :class=>'modal-footer' ),
    ]
  end

  view :modal_header do |args|
    _render_modal_title(args)
  end

  view :modal_body do |args|
    _render_core(args)
  end

  view :modal_footer do |args|
    args[:buttons] || ''
  end

  view :modal_title do |args|
    "<h4>#{_render_title args.merge(:title_class=>'modal-title')}</h4>"
  end

  view :modal do |args|
    _render_modal_slot args.merge(:optional_modal_content=>:show)
  end
=end

end
