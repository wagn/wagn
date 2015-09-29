
# The Card#abort method is for cleanly exiting an action without continuing to process any further events.
#
# Three statuses are supported:
#
#   failure: adds an error, returns false on save
#   success: no error, returns true on save
#   triumph: similar to success, but if called on a subcard it causes the entire action to abort (not just the subcard)

def abort status, msg='action canceled'
  if status == :failure && errors.empty?
    errors.add :abort, msg
  elsif Hash === status and status[:success]
    success << status[:success]
    status = :success
  end
  raise Card::Abort.new( status, msg)
end


def abortable
  yield
rescue Card::Abort => e
  if e.status == :triumph
    @supercard ? raise( e ) : true
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

# this is an override of standard rails behavior that rescues abortmakes it so that :success abortions do not rollback
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
#~~~~~~

def prepare
  @action = identify_action
  # the following should really happen when type, name etc are changed
  reset_patterns
  include_set_modules
  run_callbacks :prepare
rescue =>e
  rescue_event e
end

def approve
  @action ||= identify_action
  run_callbacks :approve
  expire_pieces if errors.any?
  errors.empty?
rescue =>e
  rescue_event e
end

def identify_action
  case
  when trash     ; :delete
  when new_card? ; :create
  else             :update
  end
end


def store
  run_callbacks :store do
    yield #unless @draft
    @virtual = false
  end
  run_callbacks :stored
rescue =>e
  rescue_event e
ensure
  @from_trash = @last_action_id = @last_content_action_id = nil
end


def extend
  run_callbacks :extend
  run_callbacks :subsequent
rescue =>e
  rescue_event e
ensure
  @action = nil
end




def rescue_event e
  @action = nil
  expire_pieces
  subcards.each do |card|
    card.expire_pieces
  end
  raise e
#rescue Card::Cancel
#  false
end

event :notable_exception_raised do
  Rails.logger.debug "BT:  #{Card::Error.current.backtrace*"\n  "}"
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



event :filter_empty_subcards, after: :approve, on: :save do
  subcards.each_card do |subcard|
    if subcard.new? && (subcard.content.empty? || subcard.content.strip.empty?) &&
      !subcard.subcards.present? && !subcard.file.present? && !subcard.image.present?   # TODO: check if file and image checks are necessary. Depends on whether attachment cards write the identifier to db_content before or after this event
      remove_subcard subcard
    end
  end
end

# left for compatibility reasons because other events refer to this
event :process_subcards, after: :filter_empty_subcards, on: :save do
end

# event :approve_subcards, after: :process_subcards do
#   subcards.process_if(:context=>self) do |sub_key, opts|
#     sub_key != key &&
#       (
#         Card[sub_key] ||
#         (opts[:content].present? && opts[:content].strip.present?) ||
#         opts[:subcards].present? || opts[:file].present? || opts[:image].present?
#       )
#   end
# end

event :approve_subcards, after: :process_subcards do
  subcards.each do |subcard|
    if !subcard.valid_subcard?
      subcard.errors.each do |field, err|
        err = "#{field} #{err}" unless [:content, :abort].member? field
        errors.add subcard.relative_name.s, err
      end
    end
  end
end

event :store_subcards, after: :store do
  subcards.each do |subcard|
    subcard.save! validate: false if subcard != self#unless @draft
  end

  # ensures that a supercard can access subcards of self
  # eg. <user> creates <user+*account> creates <user+*account+*status>
  # <user> changes <user+*account+*status> in event activate_account
  Card.write_to_cache self
end

def success
  Env.success(cardname)
end

