
# if these aren't in a nested module, the methods just overwrite the base methods,
# but we need a distict module so that super will be able to refer to the base methods.
def content
  if @selected_action_id
    @selected_content ||= begin
      (change = last_change_on( :db_content, :not_after=> @selected_action_id ) and change.value) || db_content
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
    act.actions.build(:draft => true, :card_id=>id).changes.build(:field=>:db_content, :value=>content)
  end
end

def last_change_on(field, opts={})
  where_sql =  'card_actions.card_id = :card_id AND field = :field AND (draft is not true) '
  where_sql += if opts[:before]
    'AND card_action_id < :action_id'      
  elsif opts[:not_after]
    'AND card_action_id <= :action_id'
  else
    ''
  end
  
  action_arg = opts[:before] || opts[:not_after]
  action_id = action_arg.kind_of?(Card::Action) ? action_arg.id : action_arg
  field_index = Card::TRACKED_FIELDS.index(field.to_s)
  Change.joins(:action).where( where_sql, 
    {:card_id=>id, :field=>field_index, :action_id=>action_id}
  ).order(:id).last
end

def selected_action_id
  @selected_action_id || (@current_action and @current_action.id) || last_action_id 
end

def selected_action_id= action_id
  @selected_content = nil
  @selected_action_id = action_id
end

def selected_action
  selected_action_id and Action.fetch(selected_action_id)
end

def selected_content_action_id
  @selected_action_id ||  
  (@current_action and @current_action.new_content? and @current_action.id) || 
  last_content_action_id 
end

def last_action_id
  la = last_action and la.id
end

def last_action
  actions.where('id IS NOT NULL').last
end

def last_content_action
  l_c = last_change_on(:db_content) and l_c.action
end

def last_content_action_id
  l_c = last_change_on(:db_content) and l_c.card_action_id
end

def last_actor
  last_act.actor
end

def last_act
  last_act_on_self = acts.last
  if last_act_on_self and (last_action.act == last_act_on_self or last_act_on_self.acted_at > last_action.act.acted_at)
    last_act_on_self
  else
    last_action.act
  end
end

def acted_at
  last_act.acted_at
end


def previous_action action_id
  if action_id
    action_index = actions.find_index do |a|
      a.id == action_id
    end
    actions[action_index - 1] if action_index.to_i != 0
  end
end

def revised_at
  (last_action and act=last_action.act and act.acted_at) or Time.now
end

def creator
  Card[ creator_id ]
end

def updater
  Card[ updater_id ]
end

def clean_html?
  true
end

def draft_acts
  drafts.created_by(Card::Auth.current_id).map(&:act)
end

event :detect_conflict, :before=>:approve, :on=>:update do
  if last_action_id_before_edit and last_action_id_before_edit.to_i != last_action_id and last_action.act.actor_id != Auth.current_id
    errors.add :conflict, "changes not based on latest revision"
  end
end

