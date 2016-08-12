
def virtual?
  !real?
end

format :html do
  view :core do |args|
    if card.left && Auth.signed_in?
      render_rule_editor args
    else
      fname = "#{card.cardname.left}+#{Card[:followers].name}"
      fcard = Card.fetch fname
      nest fcard, view: :titled, item: :link
    end
  end

  view :status do |_args|
    if (rcard = current_follow_rule_card)
      rcard.item_cards.map do |item|
        %(<div class="alert alert-success" role="alert">
          <strong>#{rcard.rule_set.follow_label}</strong>: #{item.title}
         </div>)
      end.join
    else
      "No following preference"
    end
  end

  view :closed_content do |_args|
    ""
  end

  #    view :editor do |args|
  #      hidden_field( :content, class: 'card-content', 'no-autosave'=>true) +
  #         (args.delete(:select_list) ? raw(render_rule_editor(args)) : super(args) )
  #    end

  view :rule_editor do |_args|
    preference_name = [
      card.left.default_follow_set_card.name,
      Auth.current.name,
      Card[:follow].name
    ].join("+")
    rule_context = Card.fetch preference_name, new: { type_id: PointerID }

    wrap_with :div, class: "edit-rule" do
      follow_context = current_follow_rule_card || rule_context
      subformat(follow_context).render_edit_rule(
        rule_context: rule_context,
        success: { view: "status", id: card.name }
      )
    end
  end

  def current_follow_rule_card
    card.left.rule_card :follow, user: Auth.current
  end
end
