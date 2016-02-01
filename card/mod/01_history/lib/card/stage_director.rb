class StageDirector
  def self.stage_index stage
    case stage
    when Symbol then return STAGE_INDEX[stage]
    when Integer then return stage
    else
      raise Card::Error, "not a valid stage: #{stage}"
    end
  end

  STAGE_INDEX = {}
  STAGES = [:initialize, :prepare_to_validate, :validate, :prepare_to_store,
            :store, :finalize, :integrate, :integrate_with_delay]
  STAGES.each_with_index do |stage, i|
    STAGE_INDEX[stage] = i
  end

  attr_accessor :subcards, :prior_store

  def initialize card, opts={}, subdirector=false
    @card = card
    @card.prepare_for_phases
    @stage = nil
    @prior_store  = opts[:priority]
    @subdirector = subdirector
    @subdirectors = []
    @subcards = Subcards.new(card)
  end

  def add_subdirector card
    @subdirectors << StageSubdirector.new(card)
    @subdirectors.last
  end

  def catch_up_to_stage next_stage
    @stage ||= -1
    (@stage + 1).upto(StageDirector.stage_index(next_stage)) do |i|
      run_single_stage STAGES[i]
    end
  end

  # TODO: get rid of recursion
  # use hash on main director to keep track of all directors
  def responsible_director card
    return self if @card == card
    @subdirectors.each do |subdir|
      (result = dir.responsible_director(card)) && return result
    end
    return false
  end

  def validation_phase
    run_single_stage :initialize
    run_single_stage :prepare_to_validate
    run_single_stage :validate
    @card.expire_pieces if @card.errors.any?
    @card.errors.empty?
  end

  def storage_phase &block
    run_single_stage :prepare_to_store
    run_single_stage :store, &block
    run_single_stage :finalize
  ensure
    @from_trash = nil
  end

  def integration_phase
    run_single_stage :integrate
    run_single_stage :integrate_with_delay
  ensure
    deep_clear_subcards
    @stage  = nil
    @action = nil
  end

  def call_after_store card, &block
    @call_after_store[card.key] ||= []
    @call_after_store[card.key] << block
  end

  def add_to_priority_queue card, subcard
    @store_priority_queue
  end

  protected

  def assign_act
    return unless c.history? || c.respond_to?(:attachment)
    @act = Card.current_director &&
           (Card.current_director.act || Card::Act.create(ip_address: Env.ip))
    @card.current_act = @act
    @card.assign_action
  end


  private

  def store &save_block
    if main? && !block_given?
      fail Card::Error, 'need block to store main card'
    end
    # the block from the around save callback that saves the card
    store_with_subcards &save_block
  end

  def store_with_subcards
    store_prior_subcards
    yield
    @call_after_store[@card.key].each do |handle_id|
      handle_id.call(@card.id)
    end
    store_subcards
    @virtual = false # TODO: find a better place for this
  end

  def store_prior_subcards
    subdirectors.each do |subdir|
      next unless subdir.prior_store
      subdir.catch_up_to_stage :store
    end
  end

  def store_subcards
    subdirectors.each do |subdir|
      next if subdir.prior_store
      subdir.catch_up_to_stage :store
    end
  end

  def main?
    !@subdirector
  end

  def run_single_stage stage, &block
    #puts "#{name}: #{stage} stage".red
    return if @card.errors.any?
    @stage = stage_index stage

    @subphase = :before
    run_callbacks :"#{stage}_stage"
    # in the store stage it can be necessary that
    # other subcards must be saved before this card gets saved
    if stage == :store
      store &block
    else
      run_subdirector_stages stage
    end
    @subphase = :after
  rescue => e
    rescue_event e
  end

  def run_subdirector_stages stage
    subdirectors.each do |subdir|
      subdir.catch_up_to_stage stage
    end
  end

end


class StageMaindirector < StageDirector
  def initialize card, opts={}
    Card.current_director = super card, opts, false
    assign_act
  end
end

class StageSubdirector < StageDirector
  def initialize card, opts={}
    super card, opts, true
    assign_act
  end

  private

  def store &block
    store_with_subcards do
      @card.skip_phases = true
      @card.save! validate: false
    end
  end

end