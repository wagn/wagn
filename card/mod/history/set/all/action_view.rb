format :html do
  def action_summary action, hide_diff
    bs_panel do
      heading do
        name_diff
      end
    end
  end

  def action_expanded action, hide_diff
    bs_panel do
      heading
      if
      body do

      end
    end
    end

  end



  def name_diff action, hide_diff
    working_name = name_changes action, hide_diff
    if action.card == card
      working_name
    else
      link_to_view(
        :related, working_name,
        path: { related: { view: "history", name: action.card.name } },
        remote: true,
        class: "slotter label label-default",
        "data-slot-selector" => ".card-slot.history-view"
      )
    end
  end

  def type_diff action, hide_diff
    action.new_type? && type_changes(action, hide_diff)
  end

  def content_diff action, action_view, hide_diff
    diff = action.new_content? &&
      action.card.format.render_content_changes(
        action: action, diff_type: action_view, hide_diff: hide_diff
      )
    return "<i>empty</i>" unless diff.present?
    diff
  end
end
