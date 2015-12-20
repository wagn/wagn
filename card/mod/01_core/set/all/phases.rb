
# The Card#abort method is for cleanly exiting an action without continuing
# to process any further events.
#
# Three statuses are supported:
#
#   failure: adds an error, returns false on save
#   success: no error, returns true on save
#   triumph: similar to success, but if called on a subcard
#            it causes the entire action to abort (not just the subcard)

def abort status, msg = 'action canceled'
  if status == :failure && errors.empty?
    errors.add :abort, msg
  elsif Hash === status && status[:success]
    success << status[:success]
    status = :success
  end
  raise Card::Abort.new(status, msg)
end

def abortable
  yield
rescue Card::Abort => e
  if e.status == :triumph
    @supercard ? raise(e) : true
  elsif e.status == :success
    if @supercard
      @supercard.subcards.delete(key)
    end
    true
  end
end

def valid_subcard?
  abortable { valid? }
end

# this is an override of standard rails behavior that rescues abort
# makes it so that :success abortions do not rollback
def with_transaction_returning_status
  status = nil
  self.class.transaction do
    add_to_transaction
    status = abortable { yield }
    raise ActiveRecord::Rollback unless status
  end
  status
end

# perhaps above should be in separate module?
# ~~~~~~

PHASES = {}
[:prepare, :approve, :store, :stored, :extend, :subsequent]
  .each_with_index do |phase, i|
    PHASES[phase] = i
  end

def run_phase phase, &block
  @phase = phase
  @subphase = :before
  if block_given?
    block.call
  else
    run_callbacks phase
  end
  @subphase = :after
end

def simulate_phase opts, &block
  @phase
end

def phase
  @phase || (@supercard && @supercard.phase)
end

def subphase
  @subphase || (@supercard && @supercard.subphase)
end

def prepare
  @action = identify_action
  # the following should really happen when type, name etc are changed
  reset_patterns
  include_set_modules
  run_phase :prepare
rescue => e
  rescue_event e
end

def approve
  @action ||= identify_action
  run_phase :approve
  expire_pieces if errors.any?
  errors.empty?
rescue => e
  rescue_event e
end

def identify_action
  case
  when trash     then :delete
  when new_card? then :create
  else :update
  end
end

def store
  run_phase :store do
    run_callbacks :store do
      yield # unless @draft
      @virtual = false
    end
  end
  run_phase :stored
rescue => e
  rescue_event e
ensure
  @from_trash =  @last_content_action_id = nil
end

def extend
  run_phase :extend
  run_phase :subsequent
rescue => e
  rescue_event e
ensure
  @action = nil
end

def rescue_event e
  @action = nil
  expire_pieces
  subcards.each(&:expire_pieces)
  raise e
  # rescue Card::Cancel
  # false
end

def phase_ok? opts
  phase && (
    (opts[:during] && in?(opts[:during])) ||
    (opts[:before] && before?(opts[:before])) ||
    (opts[:after]  && after?(opts[:after])) ||
    true # no phase restriction in opts
  )
end

def before? allowed_phase
  PHASES[allowed_phase] > PHASES[phase] ||
    (PHASES[allowed_phase] == PHASES[phase] && subphase == :before)
end

def after? allowed_phase
  PHASES[allowed_phase] < PHASES[phase] ||
    (PHASES[allowed_phase] == PHASES[phase] && subphase == :after)
end

def in? allowed_phase
  (allowed_phase.is_a?(Array) && allowed_phase.include?(phase)) ||
    allowed_phase == phase
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

def changed_condition_applies? db_column
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
