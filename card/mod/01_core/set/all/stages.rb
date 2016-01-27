STAGE_INDEX = {}
STAGES = [:initialize, :prepare_to_validate, :validate, :prepare_to_store,
          :store, :finalize, :integrate, :integrate_with_delay]
STAGES.each_with_index do |stage, i|
  STAGE_INDEX[stage] = i
end

def run_stage phase, &block
  return if errors.any?
  @phase = phase
  @stage = STAGE_INDEX[phase]
  @subphase = :before
  if block_given?
    run_callbacks :store_stage
    block.call
  else
    run_callbacks :"#{phase}_stage"
    run_stage_on_subcards phase
  end
  @subphase = :after
rescue => e
  rescue_event e
end

def catch_up_to_stage stage_index
  stage_index = STAGE_INDEX[stage_index] if stage_index.is_a?(Symbol)
  @stage ||= 0
  @stage.upto(stage_index) do |i|
    run_callbacks :"#{STAGES[i]}_stage"
  end
end

def run_stage_on_subcards stage
  subcards.catch_up_to_stage STAGE_INDEX[stage]
  handle_subcard_errors
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
  return true if @supercard

  reset_patterns
  include_set_modules
  run_stage :initialize
  run_stage :prepare_to_validate
  run_stage :validate
  expire_pieces if errors.any?
  errors.empty?
end

event :store_subcards_before_save, before: :store_stage do
#  store_prior_subcards
end

event :store_subcards_after_save, after: :store_stage do
#  store_subcards
end

def storage_phase
  return true if @supercard
  run_stage :prepare_to_store
  run_stage :store do
    store_prior_subcards
    #save_only_once(self) do
      yield
      saved_card_keys << key
      #self
      #end
    store_subcards
    @virtual = false
  end
  run_stage :finalize
ensure
  @from_trash = nil
end

def integration_phase
  return if @supercard
  run_stage :integrate
  run_stage :integrate_with_delay
ensure
  @action = nil
end

# Card.create  -> initialize