::Card.error_codes[:conflict] = [:conflict, 409]

def content
  if @selected_action_id
    @selected_content ||= begin
      (change = last_change_on( :db_content, :not_after=> @selected_action_id ) and change.value) || db_content
    end
  else
    db_content or (new_card? && template.db_content)
  end
end

def content=(value)
  @selected_content = nil
  self.db_content = value
end

def raw_content
  structure ? template.db_content : db_content
end

def chunk_list #override to customize by set
  :default
end

def label
  name
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

def save_content_draft( content )
  clear_drafts
  acts.create do |act|
    act.actions.build(:draft => true, :card_id=>id).changes.build(:field=>:db_content, :value=>content)
  end
end

def clear_drafts
  drafts.created_by(Card::Auth.current_id).each do |draft|
    draft.delete
  end
end


event :save_draft, :before=>:store, :on=>:update, :when=>proc{ |c| Env.params['draft'] == 'true' } do
  save_content_draft content
  abort :success
end


event :set_default_content, :on=>:create, :before=>:approve do  
  if !db_content_changed? and template and template.db_content.present?
    self.db_content = template.db_content
  end
end

=begin
event :protect_structured_content, :before=>:approve, :on=>:update, :changed=>:db_content do  
  if structure
    errors.add :content, "can't change; structured by #{template.name}"
  end
end
=end

event :detect_conflict, :before=>:approve, :on=>:update do
  if last_action_id_before_edit and last_action_id_before_edit.to_i != last_action_id and last_action.act.actor_id != Auth.current_id
    errors.add :conflict, "changes not based on latest revision"
  end
end