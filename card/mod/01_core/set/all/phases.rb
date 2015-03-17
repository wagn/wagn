
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
    Env.params[:success] = status[:success]
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
      @supercard.subcards.delete_if { |k,v| v==self }
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

def approve
  @action = identify_action
  # the following should really happen when type, name etc are changed
  reset_patterns
  include_set_modules
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

def store_changes
  @changed_fields = Card::TRACKED_FIELDS.select{ |f| changed_attributes.member? f }
  return unless @current_action
  if @changed_fields.present?
    @current_action.changed_fields(self, @changed_fields)
  elsif @current_action and @current_action.changes.empty?
    @current_action.delete
  end
end



def store
  run_callbacks :store do
    yield #unless @draft
    store_changes
    @virtual = false
  end
rescue =>e
  rescue_event e
ensure
  @from_trash = @last_action_id = @last_content_action_id = nil
end


def extend
  run_callbacks :extend
rescue =>e
  rescue_event e
ensure
  @action = nil
end


def rescue_event e
  @action = nil
  expire_pieces
  subcards.each do |key, card|
    next unless Card===card
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
  if opts[:on]
    return false unless Array.wrap( opts[:on] ).member? @action
  end
  if opts[:changed]
    return false if @action == :delete or !changes[ opts[:changed].to_s ]
  end
  if opts[:when]
    return false unless opts[:when].call self
  end
  true
end

def subcards
  @subcards ||= {}
end


event :process_subcards, :after=>:approve, :on=>:save do
  subcards.keys.each do |sub_name|
    opts = @subcards[sub_name] || {}
    opts = { 'content' => opts } if String===opts
    ab_name = sub_name.to_name.to_absolute_name name
    next if ab_name.key == key # don't resave self!

    opts = opts.stringify_keys
    opts['subcards'] = extract_subcard_args! opts

    opts[:supercard] = self
    
    subcard = if known_card = Card[ab_name]
      known_card.refresh.assign_attributes opts
      known_card
    elsif opts['subcards'].present? or (opts['content'].present? and opts['content'].strip.present?)
      Card.new opts.reverse_merge 'name' => sub_name
    end

    if subcard
      @subcards[sub_name] = subcard
    else
      @subcards.delete sub_name
    end
  end
end

event :approve_subcards, :after=>:process_subcards do
  subcards.each do |key, subcard|
    if !subcard.valid_subcard?
      subcard.errors.each do |field, err|
        err = "#{field} #{err}" unless [:content, :abort].member? field
        errors.add subcard.relative_name, err
      end
    end
  end
end

event :store_subcards, :after=>:store do
  subcards.each do |key, sub|
    sub.save! :validate=>false #unless @draft
  end
end


