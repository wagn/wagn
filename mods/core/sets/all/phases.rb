def approve
#  warn "approve called for #{name}!"
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
