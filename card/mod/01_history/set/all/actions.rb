# -*- encoding : utf-8 -*-

def select_action_by_params params
  action = find_action_by_params(params) and self.selected_action_id = action.id
end

def find_action_by_params args
  case 
  when args[:rev]
    nth_action args[:rev]
  when args[:rev_id]
    if action = Action.fetch(args[:rev_id]) and action.card_id == id 
      action 
    end
  end
end

def nth_action index
  index = index.to_i
  if id and index > 0
    Action.where("draft is not true AND card_id = #{id}").order(:id).limit(1).offset(index-1).first
  end
end

def revision action
  # a "revision" refers to the state of all tracked fields at the time of a given action
  if action.is_a? Integer
    action = Card::Action.fetch(action)
  end
  action and Card::TRACKED_FIELDS.inject({}) do |attr_changes, field|
    last_change = action.changes.find_by_field(field) || last_change_on(field, :not_after=>action)
    attr_changes[field.to_sym] = (last_change ? last_change.value : self[field])
    attr_changes
  end
end

def delete_old_actions
  Card::TRACKED_FIELDS.each do |field|
    # assign previous changes on each tracked field to the last action
    if (not last_action.change_for(field).present?) and (last_change = last_change_on(field))
      last_change = Card::Change.find(last_change.id)   # last_change comes as readonly record
      last_change.update_attributes!(:card_action_id=>last_action_id)
    end
  end
  actions.where('id != ?', last_action_id ).delete_all
end

