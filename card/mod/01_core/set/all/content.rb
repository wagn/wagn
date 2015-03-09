::Card.error_codes[:conflict] = [:conflict, 409]

def content
  db_content or (new_card? && template.db_content)
end

def content=(value)
  self.db_content = value
end

def raw_content
  structure ? template.db_content : content
end


format do
  def chunk_list #override to customize by set
    :default
  end
end

def label
  name
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

def save_content_draft content
  clear_drafts
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

event :detect_conflict, :before=>:approve, :on=>:update do
  if last_action_id_before_edit and last_action_id_before_edit.to_i != last_action_id and last_action.act.actor_id != Auth.current_id
    errors.add :conflict, "changes not based on latest revision"
  end
end
