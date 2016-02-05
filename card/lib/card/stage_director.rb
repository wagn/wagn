class Card
  def act opts={}
    if !Card.current_act_card
      Card.current_act_card = self
      main_act_block = true
      if opts[:success]
        Env[:success] = Success.new(cardname, Env.params[:success])
      end
    else
      main_act_block = false
    end
    yield
  ensure
    Card.clean_up_act if main_act_block
  end

  def self.clean_up_act
    Card.current_act_card = nil
    Card.directors = nil
  end

  def self.new_director card, opts={}
    if Card.current_act_card &&
       Card.current_act_card != card &&
       Card.current_act_card.director.running?
      Card.current_act_card.director.add_subdirector(card)
    else
      StageDirector.new card, main: true
    end
  end

  def self.register_director director
    Card.directors ||= {}
    Card.directors[director.card.key] = director
  end

  def self.unregister_director director
    return unless Card.directors
    Card.directors.delete director.card.key
  end

  class StageDirector
    include Stage

    def self.fetch card
      Card.directors ||= {}
      Card.directors[card.key] ||= Card.new_director card
    end

    attr_accessor :subcards, :prior_store, :act, :card, :stage

    def initialize card, opts={}, main=true
      @card = card
      @card.director = self
      @card.prepare_for_phases
      @call_after_store = []
      @stage = nil
      @running = false
      @parent = opts[:parent]
      # Has card to be stored before the supercard?
      @prior_store = opts[:priority]
      @main = main
      @subdirectors = []
      register
    end

    def subcards
      @subcards ||= Subcards.new(card)
    end

    def register
      Card.register_director self
    end

    def unregister
      @card.director = nil
      @subdirectors = nil
      @stage = nil
      @action = nil
      Card.unregister_director self
    end

    def running?
      @running
    end

    def add_subdirector card
      subdir = StageSubdirector.new(card, parent: self)
      @subdirectors << subdir
      subdir
    end

    def catch_up_to_stage next_stage
      @stage ||= -1
      (@stage + 1).upto(stage_index(next_stage)) do |i|
        run_single_stage stage_symbol(i)
      end
    end

    def validation_phase
      @running = true
      run_single_stage :initialize
      run_single_stage :prepare_to_validate
      run_single_stage :validate
      @card.expire_pieces if @card.errors.any?
      @card.errors.empty?
    end

    def storage_phase &block
      run_single_stage :prepare_to_store if main?
      run_single_stage :store, &block
      run_single_stage :finalize
    ensure
      @from_trash = nil
    end

    def integration_phase
      run_single_stage :integrate
      run_single_stage :integrate_with_delay
    ensure
      unregister
    end

    def call_after_store &block
      @call_after_store << block
    end

    def add_to_priority_queue card, subcard
      @store_priority_queue
    end

    def need_act
      act_director = main_director
      if !act_director
        fail Card::Error, 'act requested without a main stage director'
      end
      act_director.act ||=  Card::Act.create(ip_address: Env.ip)
      @card.current_act = @act = act_director.act
    end

    def main_director
      if main?
        self
      elsif Card.current_act_card
        Card.current_act_card.director
      elsif @parent
        @parent.main_director
      end
    end

    def main?
      @main
    end

    private

    def rescue_event e
      @card.action = nil
      @card.expire_pieces
      @subcards.each(&:expire_pieces) if @subcards
      raise e
    end

    def store &save_block
      if main? && !block_given?
        fail Card::Error, 'need block to store main card'
      end
      # the block from the around save callback that saves the card
      if block_given?
        run_stage_callbacks :store
        store_with_subcards &save_block
      else
        store_and_finalize_as_subcard
      end
    end

    def store_with_subcards
      store_prior_subcards
      yield
      @call_after_store.each do |handle_id|
        handle_id.call(@card.id)
      end
      store_subcards
      @virtual = false # TODO: find a better place for this
    ensure
      @card.handle_subcard_errors
    end

    def store_prior_subcards
      @subdirectors.each do |subdir|
        next unless subdir.prior_store
        subdir.catch_up_to_stage :store
      end
    end

    def store_subcards
      @subdirectors.each do |subdir|
        next if subdir.prior_store
        subdir.catch_up_to_stage :store
      end
    end

    def run_single_stage stage, &block
      # puts "#{name}: #{stage} stage".red
      return if @card.errors.any?
      @stage = stage_index stage

      # in the store stage it can be necessary that
      # other subcards must be saved before this card gets saved
      if stage == :store
        store &block
      else
        run_stage_callbacks stage
        run_subdirector_stages stage unless stage == :finalize
      end
    rescue => e
      rescue_event e
    end

    def store_and_finalize_as_subcard
      @card.skip_phases = true
      @card.save! validate: false
    end

    def run_stage_callbacks stage
      @card.run_callbacks :"#{stage}_stage"
    end

    def run_subdirector_stages stage
      @subdirectors.each do |subdir|
        subdir.catch_up_to_stage stage
      end
    ensure
      @card.handle_subcard_errors
    end
  end

  class StageSubdirector < StageDirector
    def initialize card, opts={}
      super card, opts, false
    end
  end
end


