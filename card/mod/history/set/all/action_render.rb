#! no set module

class ActionRender
  def initialize action, hide_diff=false
    @action = action
    @hide_diff = hide_diff
  end

  def name_diff
    working_name = name_changes @action, @hide_diff
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

  def type_diff
    action.new_type? && type_changes
  end

  def content_diff action_view
    diff = action.new_content? &&
      action.card.format.render_content_changes(
        action: action, diff_type: action_view, hide_diff: hide_diff
      )
    return "<i>empty</i>" unless diff.present?
    diff
  end

  def type_changes
    change = @hide_diff ? action.value(:cardtype) : action.cardtype_diff
    "(#{change})"
  end
end
