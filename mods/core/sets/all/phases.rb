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
    @subcards.each { |card| card.expire_pieces }
  end
  raise e
end

def event_applies? opts
  if !opts[:on] or Array.wrap( opts[:on] ).member? @action
    if opts[:when]
      opts[:when].call self
    else
      true
    end
  end
end



event :process_subcards, :after=>:approve, :on=>:save do
  @subcards = []
  (cards || {}).each_pair do |sub_name, opts|
    opts[:nested_edit] = self
    absolute_name = sub_name.to_name.post_cgi.to_name.to_absolute_name cardname

    next if absolute_name.key == key # don't resave self!
    subcard = if existing_card = Card[absolute_name]
      existing_card.refresh.assign_attributes opts
    elsif opts[:content].present? and opts[:content].strip.present?
      Card.new opts.merge( :name => absolute_name, :loaded_left => self )
    end

    @subcards << subcard if subcard
  end
end

event :approve_subcards, :after=>:process_subcards do
  @subcards.each do |subcard|
    if !subcard.valid?
      subcard.errors.each do |field, err|
        errors.add field, "problem with #{subcard.name}: #{err}"
      end
    end
  end
end

event :store_subcards, :after=>:store do
  @subcards.each do |sub|
    sub.save! :validate=>false
  end
end

