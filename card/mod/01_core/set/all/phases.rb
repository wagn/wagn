
# The Card#abort method is for cleanly exiting an action without continuing
# to process any further events.
#
# Three statuses are supported:
#
#   failure: adds an error, returns false on save
#   success: no error, returns true on save
#   triumph: similar to success, but if called on a subcard
#            it causes the entire action to abort (not just the subcard)

def self.create! opts
  card = Card.new opts
  card.act do
    card.save!
  end
  card
end

def self.create opts
  card = Card.new opts
  card.act do
    card.save
  end
  card
end

def delete
  act do
    super
  end
end

def delete!
  act do
    super
  end
end

def update_attributes opts
  act do
    super opts
  end
end

def update_attributes! opts
  act do
    super opts
  end
end

def abort status, msg='action canceled'
  if status == :failure && errors.empty?
    errors.add :abort, msg
  elsif status.is_a?(Hash) && status[:success]
    success << status[:success]
    status = :success
  end
  fail Card::Abort.new(status, msg)
end

def abortable
  yield
rescue Card::Abort => e
  if e.status == :triumph
    @supercard ? raise(e) : true
  elsif e.status == :success
    if @supercard
      @supercard.subcards.delete key
      @supercard.director.subdirectors.delete self
      expire_soft
    end
    true
  end
end

# this is an override of standard rails behavior that rescues abort
# makes it so that :success abortions do not rollback
def with_transaction_returning_status
  status = nil
  self.class.transaction do
    add_to_transaction
    status = abortable { yield }
    fail ActiveRecord::Rollback unless status
  end
  status
end

# perhaps above should be in separate module?
# ~~~~~~

def rescue_event e
  @action = nil
  expire_pieces
  subcards.each(&:expire_pieces)
  raise e
  # rescue Card::Cancel
  # false
end

event :notable_exception_raised do
  Rails.logger.debug "BT:  #{Card::Error.current.backtrace * "\n  "}"
end

def event_applies? opts
  on_condition_applies?(opts[:on]) &&
    changed_condition_applies?(opts[:changed]) &&
    when_condition_applies?(opts[:when])
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

def success
  Env.success(cardname)
end

def prepare_for_phases
  identify_action
  reset_patterns
  include_set_modules
end

def run_phases?
  director.main? && !skip_phases
end

def validation_phase
  director.validation_phase
end

def storage_phase &block
  director.storage_phase(&block)
end

def integration_phase
  director.integration_phase
end

def clean_up
  Card::DirectorRegister.clear
end
