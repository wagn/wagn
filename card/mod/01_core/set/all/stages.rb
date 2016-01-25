def run_stage phase, &block
  return if errors.any?
  @phase = phase
  @subphase = :before
  if block_given?
    block.call
  else
    run_callbacks :"#{phase}_stage"
  end
  @subphase = :after
  run_phase_on_subcards phase
rescue => e
  rescue_event e
end

def run_phase_on_subcards phase
  subcards.each do |subcard|
    subcard.run_callbacks :"#{phase}_stage"
  end
end

event :identify_action, before: :initialize_stage do
  @action =
    case
    when trash     then :delete
    when new_card? then :create
    else :update
    end
end

def validation_phase
  return if @supercard

  reset_patterns
  include_set_modules
  run_stage :initialize
  run_stage :prepare_to_validate
  run_stage :validate
  expire_pieces if errors.any?
  errors.empty?
end

def storage_phase
  return if @supercard
  run_phase :prepare_to_store
  run_phase :store do
    store_pre_subcards
    yield
    store_post_subcards
    @virtual = false
  end
  run_phase :prepare_to_finalize
  run_phase :finalize
ensure
  @from_trash = nil
end

def integration_phase
  return if @supercard
  run_phase :integrate
  run_phase :integrate_with_delay
ensure
  @action = nil
end

# Card.create  -> initialize