
def save args={}
  abortable { super }
end

def save! args={}
  abortable { super }
end

def valid_subcard?
  abortable { valid? }
end

def abortable
  yield
rescue Card::Abort => e
  # need mechanism for subcards to abort entire process?
  e.status == :success
end


def abort status=:failure, msg='action canceled'
  if status == :failure && errors.empty?
    errors.add :abort, msg
  end
  raise Card::Abort.new( status, msg)
end

def approve
  #warn "approve called for #{name}!"
  @action = case
    when trash     ; :delete
    when new_card? ; :create
    else             :update
    end

  # the following should really happen when type, name etc are changed
  reset_patterns
  include_set_modules
  
  run_callbacks :approve
  expire_pieces if errors.any?
  errors.empty?
rescue Exception=>e
  rescue_event e
end


def store
  run_callbacks :store do
    yield
    @virtual = false
  end
rescue Exception=>e
  rescue_event e
ensure
  @from_trash = nil
end


def extend
#    puts "extend called"
  run_callbacks :extend
rescue Exception=>e
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
    opts = @subcards[sub_name]
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
    sub.save! :validate=>false
  end
end


