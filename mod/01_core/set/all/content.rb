::Card.error_codes[:conflict] = [:conflict, 409]

def content
  #binding.pry
  db_content or (new_card? && template.db_content)
#  if new_card? || selected_action_id == last_action_id
  #return db_content
  # else
  #   return revision(selected_action_id)[:db_content]
  # end
 # byebug
 #old: current_revision.content
  # if new_card?
  #   db_content
  # elsif template && template.db_content.present?
  #   template.db_content
  # end
  # if db_content.nil? && new_card?
  #   template.db_content
  # else
  #   db_content
  # end
  # # else
  #   db_content
  # end
end

def selected_content  
  content  #not sure whether this should be the standard behavior of content
end

# def db_content=(value)
#   #aattribute_will_change!('content') if self.db_content != value
#   #write_attribute(:db_content, value)
#   self[:db_content] = value
# end

#content is not part of the db so we have to add tracking
def content=(value)
  #binding.pry
  #attribute_will_change!('content') if db_content != value
  self.db_content = value
end
# def content_changed?
#   changed.include?('content')
# end


def raw_content
  structure ? template.db_content : db_content
end

def chunk_list #override to customize by set
  :default
end

def selected_action_id
  @selected_action_id || (@current_action and @current_action.id) || last_action_id || 0
end

def selected_action
  Card::Action.find(selected_action_id)
end

def selected_content_action_id
  @selected_action_id ||  (@current_action and @current_action.new_content? and  @current_action.id) || last_content_action_id 
end
def selected_content_action
  Card::Action.find(selected_content_action_id)
end


def last_action_id
  last_action and last_action.id
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


def current_revision
  #return current_revision || Card::Revision.new
  if @cached_revision and @cached_revision.id==current_revision_id
  elsif ( Card::Revision.cache &&
     @cached_revision=Card::Revision.cache.read("#{cardname.safe_key}-content") and
     @cached_revision.id==current_revision_id )
  else
    rev = current_revision_id ? Card::Revision.find(current_revision_id) : Card::Revision.new()
    @cached_revision = Card::Revision.cache ?
      Card::Revision.cache.write("#{cardname.safe_key}-content", rev) : rev
  end
  @cached_revision
end


def previous_revision action_id
  # if previous_action_id
  #   rev_index = revisions.find_index do |rev|
  #     rev.id == revision_id
  #   end
  #   revisions[rev_index - 1] if rev_index.to_i != 0
  # end
end
# old
# def previous_revision revision_id
#   if revision_id
#     rev_index = revisions.find_index do |rev|
#       rev.id == revision_id
#     end
#     revisions[rev_index - 1] if rev_index.to_i != 0
#   end
# end
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
  save_content_draft Env.params['card[content]']
  abort :success
end


event :set_default_content, :on=>:create, :before=>:approve do  
  if !db_content_changed? and template and template.db_content.present?
    self.db_content = template.db_content
  end
end

event :protect_structured_content, :before=>:approve, :on=>:update, :changed=>:db_content do  
  if structure
    errors.add :content, "can't change; structured by #{template.name}"
  end
end


event :detect_conflict, :before=>:approve, :on=>:update do   #ACT
  if last_action_id_before_edit and last_action_id_before_edit.to_i != last_action_id
    errors.add :conflict, "changes not based on latest revision"
  end
end