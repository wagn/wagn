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
  if @subcards
    @subcards.each { |key, card| card.expire_pieces }
  end
  raise e
rescue Card::Cancel
  false
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

event :process_subcards, :after=>:approve, :on=>:save do
  @subcards = {}
  (cards || {}).each do |sub_name, opts|
    next if sub_name.to_name.key == key # don't resave self!

    opts[:supercard] = self    
    subcard = if known_card = Card[sub_name]
      known_card.refresh.assign_attributes opts
      known_card
    elsif opts[:content].present? and opts[:content].strip.present?
      Card.new opts.merge :name => sub_name
    end

    @subcards[sub_name] = subcard if subcard
  end
end

event :approve_subcards, :after=>:process_subcards do
  @subcards.each do |key, subcard|
    if !subcard.valid?
      subcard.errors.each do |field, err|
        errors.add field, "#{subcard.relative_name}: #{err}"
      end
    end
  end
end

event :store_subcards, :after=>:store do
  @subcards.each do |key, sub|
    sub.save! :validate=>false
  end
end

#~~~~~~~~~~~~~~~~
# EXPERIMENTAL
# the following methods are for visualing card events
#  not ready for prime time!

def events action
  @action = action
  root = _validate_callbacks + _save_callbacks
  events = [ events_tree(:validation), events_tree(:save)]
  @action = nil
  puts_events events
end

private

def puts_events events, prefix='', depth=0
  r = ''
  depth += 1
  events.each do |e|
    space = ' ' * (depth * 2)

    #FIXME - this is not right.  before and around callbacks are processed in declaration order regardless of kind.
    # not all befores then all arounds
    
    if e[:before]
      r += puts_events( e[:before], space+'v  ', depth)
    end
    if e[:around]
      r += puts_events( e[:around], space+'vv ', depth )
    end
    
    
    output = "#{prefix}#{e[:name]}"
    warn output
    r+= "#{output}\n"
    
    if e[:after]
      r += puts_events( e[:after ].reverse, space+'^  ', depth )
    end
  end
  r
end

def events_tree filt
  hash = {:name => filt }
  if respond_to? "_#{filt}_callbacks"
    send( "_#{filt}_callbacks" ).each do |callback|
      next unless callback.applies? self
      hash[callback.kind] ||= []    
      hash[callback.kind] << events_tree( callback.filter )
    end
  end
  hash
end
#FIXME - this doesn't belong here!!

class ::ActiveSupport::Callbacks::Callback
  def applies? object
    object.send :eval, "value=nil;halted=false;!!(#{@compiled_options})"
  end
end

