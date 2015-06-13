include All::Permissions::Follow

def option_cards
  Card::FollowOption.cards.compact
end

def options_rule_card
  Card.new :name=>'follow_options_card', :type_code=>:pointer, :content=>option_cards.map {|oc| "[[#{oc.title}]]" }.join("\n")
end


format :html do
  def default_follow_item_args args
    args[:condition] ||= Env.params[:condition] || '*always'
  end

  view :follow_item, :tags=>:unknown_ok do |args|
    if card.new_card? || !card.include_item?(args[:condition])
      button_view = :add_follow_rule_button
      form_opts = {:add_item=>args[:condition]}
    else
      button_view = :delete_follow_rule_button
      form_opts = {:drop_item=>args[:condition]}
    end

    text = if (option_card = Card.fetch args[:condition])
             option_card.description(card.rule_set)
           else
             card.rule_set.follow_label
           end
    link_target = if card.rule_set.tag.codename == 'self'
                    card.rule_set_name.left
                  else
                    "#{card.rule_set_name}+by name"
                  end
    wrap do
      card_form({:action=>:update, :name=>card.name, :success=>{:view=>:follow_item}},
              :hidden=>{:condition=>args[:condition]}.merge(form_opts)) do
        output [
          _optional_render(button_view, args),
          card_link( link_target, :text=>text)
        ]
      end
    end
  end

  def default_modal_content_args args
    args[:card_key] ||= card.set_prototype.key
  end

  view :modal_header do |args|
    %{
      #{ link_to '&times;', '', 'aria-hidden'=>true, :class=>'close update-follow-link', 'data-dismiss'=>'modal', 'data-card_key'=>args[:card_key] }
       <h4 class="modal-title">Get notified about changes</h4>
    }
  end

  view :modal_body do |args|
    wrap_with :ul, :class=>'delete-list list-group' do
      card.item_names.map do |option|
        content_tag :li, :class=>'list-group-item' do
          subformat(card).render_follow_item :condition=>(option == '*never' ? '*always' : option)
        end
      end.join "\n"
    end
  end


  view :modal_footer do |args|
    card_link(args[:card_key], :text=>'more options', :path_opts=>{:view=>:related, :related=>{:name=>card.name,:view=>:related_edit_rule}}, :class=>'btn update-follow-link', 'data-card_key'=>args[:card_key]) +
      link_to('Close', '', :class=>'btn btn-default update-follow-link', 'data-dismiss'=>'modal', 'data-card_key'=>args[:card_key])
  end

  view :delete_follow_rule_button do |args|
    button_tag :type=>:submit, :class=>'btn-xs btn-item-delete btn-primary', 'aria-label'=>'Left Align' do
      tag :span, :class=>"glyphicon glyphicon-ok", 'aria-hidden'=>"true"
    end

  end

  view :add_follow_rule_button do |args|
    button_tag :type=>:submit, :class=>'btn-xs btn-item-add', 'aria-label'=>'Left Align' do
      tag :span, :class=>"glyphicon glyphicon-plus", 'aria-hidden'=>"true"
    end
  end

end