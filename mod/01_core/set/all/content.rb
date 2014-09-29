::Card.error_codes[:conflict] = [:conflict, 409]

#ACT<content> IMPORTANT
def content
#  if new_card? || selected_action_id == last_action_id
    return db_content
  # else
  #   return revision(selected_action_id)[:db_content]
  # end
 # byebug
 #  if !new_card?
 #    db_content
 #    #old: current_revision.content
 #  elsif template && template.content.present?
 #    template.content
 #  end
end

def selected_content  
  content  #not sure whether this should be the standard behavior of content
end

#content is not part of the db so we have to add tracking
def content=(value)
  attribute_will_change!('content') if db_content != value
  self.db_content = value
end
def content_changed?
  changed.include?('content')
end


def raw_content
  structure ? template.db_content : db_content  #ACT<content> IMPORTANT
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
  @selected_action_id || last_content_action_id
end
def selected_content_action
  Card::Action.find(selected_content_action_id)
end


def last_action_id
  last_action and last_action.id
end
def last_action
  actions.last
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


def save_draft( content )
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

def clean_html?
  true
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


# event :detect_conflict, :before=>:approve, :on=>:update do   #ACT
#   if current_revision_id_changed?# && current_revision_id.to_i != current_revision_id_was.to_i
#     @current_revision_id = current_revision_id_was
#     errors.add :conflict, "changes not based on latest revision"
#   end
# end