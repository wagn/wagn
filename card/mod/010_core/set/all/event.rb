EVENT_CONDITIONS = [:set, :on, :changed, :when].freeze

def event_applies? opts
  EVENT_CONDITIONS.all? do |key|
    send "#{key}_condition_applies?", opts[key]
  end
end

private

def set_condition_applies? set_module
  singleton_class.include?(set_module)
end

def on_condition_applies? actions
  actions = Array(actions).compact
  return true if actions.empty?
  actions.include? @action
end

def changed_condition_applies? db_columns
  db_columns = Array(db_columns).compact
  return true if db_columns.empty?
  db_columns.any? { |col| single_changed_condition_applies? col }
end

def when_condition_applies? block
  return true unless block
  block.call(self)
end

def single_changed_condition_applies? db_column
  return true unless db_column
  db_column =
    case db_column.to_sym
    when :content then "db_content"
    when :type    then "type_id"
    else db_column.to_s
    end
  @action != :delete && changes[db_column]
end

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
