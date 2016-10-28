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
    alert :success, true do
      content_tag(:h5, "restored") + subformat(res_card).render_closed
    end
  end

  def empty_trash_link
    content_tag(
      :p,
      button_link("empty trash",
                  btn_type: :default,
                  path: { card: :admin, action: :update, task: :empty_trash,
                          success: { id: "~#{card.id}" } },
                  "data-confirm" => "Are you sure you want to delete "\
                                    "all cards in the trash?")
    )
  end

  def history_link trashed_card
    link_to_card trashed_card, "history",
                 path: { view: :history, look_in_trash: true }
  end

  def restore_link trashed_card
    before_delete = trashed_card.actions[-2]
    link_to "restore", method: :post,
                       rel: "nofollow",
                       remote: true,
                       class: "slotter",
                       path: { id: trashed_card.id,
                               view: :open,
                               look_in_trash: true,
                               action: :update,
                               restore: trashed_card.id,
                               action_ids: [before_delete],
                               success: { id: "~#{card.id}" } }
  end
end
