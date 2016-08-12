::Card.error_codes[:conflict] = [:conflict, 409]

def content
  db_content || (new_card? && template.db_content)
end

def content= value
  self.db_content = value
end

def raw_content
  structure ? template.db_content : content
end

format do
  def chunk_list # override to customize by set
    :default
  end
end

def label
  name
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

def save_content_draft _content
  clear_drafts
end

def clear_drafts
  drafts.created_by(Card::Auth.current_id).each(&:delete)
end

def last_draft_content
  drafts.last.card_changes.last.value
end

event :save_draft, :store,
      on: :update, when: proc { Env.params["draft"] == "true" } do
  save_content_draft content
  abort :success
end

event :set_default_content, :prepare_to_validate,
      on: :create, when: proc { |c| c.use_default_content? } do
  self.db_content = template.db_content
end

def use_default_content?
  !db_content_changed? && template && template.db_content.present?
end
