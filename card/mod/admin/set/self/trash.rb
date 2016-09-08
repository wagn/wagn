format :html do
  def trashed_cards
    Card.where(trash: true)
  end

  view :core do |args|
    rows =
      trashed_cards.map do |card|
        [card.name, Card[card.updater_id].name, put_back_link(card)]
      end
    output [
      (content_tag(:p, empty_trash_link) if rows.present?),
      table(rows, header: ['card','deleted by',''])
    ]
  end

  def empty_trash_link
    card_link :admin, path_opts: { action: :update, task: :empty_trash,
                                   success: { id: "~#{card.id}" } },
                      text: "empty trash"
  end

  def put_back_link card
    before_delete = card.actions[-2]
    link_path = path action: :update, view: :open, action_ids: [before_delete],
                     success: { id: card.name }
    link_to "put back", link_path, method: :post, rel: "nofollow"
  end
end
