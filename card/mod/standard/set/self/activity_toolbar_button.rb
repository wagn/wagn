include_set Abstract::ToolbarSplitButton

format :html do
  view :core do
    subject.toolbar_split_button "activity", view: :history, icon: :time do
      {
        history: (subject._render_history_link if card.history?),
        discussion: subject.link_to_related(:discussion, "discuss"),
        follow:  subject._render_follow_link,
        editors: subject.link_to_related(:editors, "editors")
      }
    end
  end
end
