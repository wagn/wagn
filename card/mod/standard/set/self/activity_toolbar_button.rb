include_set Abstract::ToolbarSplitButton

format :html do
  view :core do
    subject.toolbar_split_button "activity", view: :history, icon: :history do
      {
        history: (subject._render_history_link if card.history?),
        discussion: subject.link_to_related(:discussion, "discuss", class: "dropdown-item"),
        follow:  subject._render_follow_link(link_opts: { class: "dropdown-item" }),
        editors: subject.link_to_related(:editors, "editors", class: "dropdown-item")
      }
    end
  end
end
