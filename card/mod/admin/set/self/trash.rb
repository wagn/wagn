format :html do
  view :core do |_args|
    rows = trashed_cards.map { |tc| trash_table_row(tc) }
    output [
      restored,
      (empty_trash_link if rows.present?),
      table(rows, header: ["card", "deleted", "by", ""])
    ]
  end

  def trashed_cards
    Card.where(trash: true).order(updated_at: :desc)
  end

  def trash_table_row card
    [
      card.name,
      "#{time_ago_in_words(card.updated_at)} ago",
      Card[card.updater_id].name,
      "#{history_link(card)} | #{restore_link(card)}"
    ]
  end

  def restored
    return unless (res_id = Env.params[:restore]) &&
                  (res_card = Card[res_id.to_i])
    alert :success, dismissible: true do
      content_tag(:h5, "restored") + subformat(res_card).render_closed
    end
  end

  def empty_trash_link
    button =
      button_link "empty trash",
                  { card: :admin, action: :update,
                    task: :empty_trash, success: { id: "~#{card.id}" } },
                  btn_type: :default,
                  "data-confirm" => "Are you sure you want to delete all "\
                                    "cards in the trash"
    content_tag :p, button
  end

  def history_link trashed_card
    card_link trashed_card, path_opts: { view: :history, look_in_trash: true },
                            text: "history"
  end

  def restore_link trashed_card
    before_delete = trashed_card.actions[-2]
    link_path = path id: trashed_card.id, look_in_trash: true, action: :update,
                     view: :open, restore: trashed_card.id,
                     action_ids: [before_delete], success: { id: "~#{card.id}" }
    link_to "restore", link_path, method: :post, rel: "nofollow",
                                  remote: true, class: "slotter"
  end
end
