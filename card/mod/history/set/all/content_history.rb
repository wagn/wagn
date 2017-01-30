
# if these aren't in a nested module, the methods just overwrite the base
#  methods, but we need a distict module so that super will be able to refer to
# the base methods.
def content
  if @selected_action_id
    @selected_content ||= begin
      change = last_change_on :db_content, not_after: @selected_action_id,
                                           including_drafts: true
      (change && change.value) || db_content
    end
  else
    super
  end
end

def content= value
  @selected_content = nil
  super
end

def save_content_draft content
  super
  acts.create do |act|
    act.actions.build(draft: true, card_id: id, action_type: :update)
       .card_changes.build(field: :db_content, value: content)
  end
end

def last_change_on field, opts={}
  Change.joins(:action).where(
    last_change_sql_conditions(opts),
    card_id: id,
    action_id: extract_action_id(opts[:before] || opts[:not_after]),
    field: Card::Change.field_index(field)
  ).order(:id).last
end

def extract_action_id action_arg
  action_arg.is_a?(Card::Action) ? action_arg.id : action_arg
end

def last_change_sql_conditions opts
  cond = "card_actions.card_id = :card_id AND field = :field"
  cond += " AND (draft is not true)" unless opts[:including_drafts]
  operator = "<" if opts[:before]
  operator = "<=" if opts[:not_after]
  cond += " AND card_action_id #{operator} :action_id" if operator
  cond
end

def selected_action_id
  @selected_action_id || (@current_action && @current_action.id) ||
    last_action_id
end

def selected_action_id= action_id
  @selected_content = nil
  @selected_action_id = action_id
end

def selected_action
  selected_action_id && Action.fetch(selected_action_id)
end

def with_selected_action_id action_id
  current_action_id = @selected_action_id
  select_action_id action_id
  result = yield
  select_action_id current_action_id
  result
end

def select_action_id action_id
  run_callbacks :select_action do
    self.selected_action_id = action_id
  end
end

def selected_content_action_id
  @selected_action_id || new_content_action_id || last_content_action_id
end

def new_content_action_id
  return unless @current_action && current_action_changes_content?
  @current_action.id
end

def current_action_changes_content?
  new_card? || @current_action.new_content? || db_content_changed?
end

def last_action_id
  (la = last_action) && la.id
end

def last_action
  actions.where("id IS NOT NULL").last
end

def last_content_action
  l_c = last_change_on :db_content
  l_c && l_c.action
end

def last_content_action_id
  l_c = last_change_on :db_content
  l_c && l_c.card_action_id
end

def last_actor
  last_act.actor
end

def last_act
  @last_act ||=
    if (action = last_action)
      last_act_on_self = acts.last
      if last_act_on_self && action.act &&
         (action.act == last_act_on_self ||
         last_act_on_self.acted_at > action.act.acted_at)
        last_act_on_self
      else
        action.act
      end
    end
end

def acted_at
  last_act.acted_at
end

def previous_action action_id
  return unless action_id
  action_index = actions.find_index { |a| a.id == action_id }
  actions[action_index - 1] if action_index.to_i.nonzero?
end

def revised_at
  (last_action && (act = last_action.act) && act.acted_at) || Time.zone.now
end

def creator
  Card[creator_id]
end

def updater
  Card[updater_id]
end

def clean_html?
  true
end

def draft_acts
  drafts.created_by(Card::Auth.current_id).map(&:act)
end

event :detect_conflict, :validate, on: :update,
                                   when: proc { |c| c.edit_conflict? } do
  errors.add :conflict, "changes not based on latest revision"
end

def edit_conflict?
  last_action_id_before_edit &&
    last_action_id_before_edit.to_i != last_action_id &&
    (la = last_action) &&
    la.act.actor_id != Auth.current_id
end
