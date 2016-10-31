format :html do
  def default_action_expanded_args args
    args[:action] ||= action_from_params || card.last_action
    args[:header] ||= params[:header]
  end

  view :action_expanded do |args|
    render_action_content args[:action], :expanded
  end

  def default_action_summary_args args
    default_action_expanded_args args
  end

  view :action_summary do |args|
    render_action_content args[:action], :summary
  end

  view :action_content_toggle do |args|
    toggle_action_content_link args[:action], args[:view_type]
  end

  def render_action_content action, view_type
    return "" unless action.present?
    wrap do
      [
        action_content_toggle(action, view_type),
        content_diff(action, view_type)
      ]
    end
  end

  def content_diff action, view_type
    diff = action.new_content? &&
           _render_content_changes(action: action, diff_type: view_type) #, hide_diff: @hide_diff
    return "<i>empty</i>" unless diff.present?
    diff
  end

  def action_from_params
    return unless (action_id = params[:action_id])
    Action.find action_id
  end

  def action_content_toggle action, view_type
    #return unless show_action_content_toggle?(action, view_type)
    toggle_action_content_link action, view_type
  end

  def show_action_content_toggle? action, view_type
    action.summary_diff_omits_content? || view_type == :expanded
  end

  def toggle_action_content_link action, view_type
    other_view_type = view_type == :expanded ? :summary : :expanded
    link_to_view "action_#{other_view_type}",
                 glyphicon(arrow_dir(view_type)),
                 class: "slotter revision-#{action.card_act_id} pull-right",
                 path: { action_id: action.id, look_in_trash: true }
  end

  def arrow_dir view_type
    view_type == :expanded ? "triangle-left" : "triangle-right"
  end
end
