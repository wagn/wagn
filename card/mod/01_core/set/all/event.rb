def event_applies? opts
  on_condition_applies?(opts[:on]) &&
    changed_condition_applies?(opts[:changed]) &&
    when_condition_applies?(opts[:when])
end

def rescue_event e
  @action = nil
  expire_pieces
  subcards.each(&:expire_pieces)
  raise e
  # rescue Card::Cancel
  # false
end

private

def wrong_stage opts
  return false if director.stage_ok? opts
  if !stage
    "phase method #{method} called outside of event phases"
  else
    "#{opts.inspect} method #{method} called in stage #{stage}"
  end
end

def wrong_action action
  return false if on_condition_applies? action
  "on: #{action} method #{method} called on #{@action}"
end

def on_condition_applies? action
  if action
    Array.wrap(action).member? @action
  else
    true
  end
end

def changed_condition_applies? db_columns
  case db_columns
  when Symbol
    return single_changed_condition_applies?(db_columns)
  when Array
    db_columns.each do |col|
      return true if single_changed_condition_applies? col
    end
  else
    return  true
  end
  false
end

def single_changed_condition_applies? db_column
  if db_column
    db_column =
      case db_column.to_sym
      when :content then 'db_content'
      when :type    then 'type_id'
      else db_column.to_s
      end
    @action != :delete && changes[db_column]
  else
    true
  end
end

def when_condition_applies? block
  if block
    block.call self
  else
    true
  end
end
