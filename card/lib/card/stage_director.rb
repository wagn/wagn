
class Card
  # A 'StageDirector' executes the stages of a card when the card gets created,
  # updated or deleted.
  # For subcards, i.e. other cards that are changed in the same act, a
  # StageDirector has StageSubdirectors that take care of the stages for
  # those cards
  #
  # In general a stage is executed for all involved cards before the
  # StageDirector proceeds with the next stage.
  # Only exception is the finalize stage.
  # The finalize stage of a subcard is executed immediately after its store
  # stage. When all subcards are finalized the supercard's finalize stage is
  # executed.
  #
  # If a subcard is added in a stage then it catches up at the end of the stage
  # to the current stage.
  # For example if you add a subcard in a card's :prepare_to_store stage then
  # after that stage the stages :initialize, :prepare_to_validate,
  # :validate and :prepare_to_store are executed for the subcard.
  #
  # Stages are executed with pre-order depth-first search.
  # That means if A has subcards AA and AB; AAA is subcard of AA and ABA
  # subcard of AB then the order of execution is
  # A -> AA -> AAA -> AB -> ABA
  #
  # A special case can happen in the store phase.
  # If the id of a subcard is needed for a supercard
  # (for example as left_id or as type_id) and the subcard doesn't
  # have an id yet (because it gets created in the same act)
  # then the subcard's store stage is executed before the supercard's store
  # stage
  class StageDirector
    include Stage

    attr_accessor :prior_store, :act, :card, :stage, :parent, :main,
                  :subdirectors
    attr_reader :running
    alias running? running
    alias main? main

    def initialize card, opts={}, main=true
      @card = card
      @card.director = self
      # for read actions there is no validation phase
      # so we have to set the action here
      @card.identify_action

      @stage = nil
      @running = false
      @prepared = false
      @parent = opts[:parent]
      # has card to be stored before the supercard?
      @prior_store = opts[:priority]
      @main = main
      @subdirectors = SubdirectorArray.initialize_with_subcards(self)
      register
    end

    def register
      Card::DirectorRegister.add self
    end

    def unregister
      Card::DirectorRegister.delete self
    end

    def delete
      @card.director = nil
      @subdirectors.clear
      @stage = nil
      @action = nil
    end

    def prepare_for_phases
      @card.prepare_for_phases unless @prepared
      @prepared = true
      @subdirectors.each(&:prepare_for_phases)
    end

    def validation_phase
      run_single_stage :initialize
      run_single_stage :prepare_to_validate
      run_single_stage :validate
      @card.expire_pieces if @card.errors.any?
      @card.errors.empty?
    end

    # everything in here can use dirty marks
    def storage_phase &block
      # for a subcard :prepare_to_store was already executed
      # don't execute it twice
      catch_up_to_stage :prepare_to_store
      run_single_stage :store, &block
      run_single_stage :finalize
    ensure
      @from_trash = nil
    end

    # dirty marks are gone in this phase
    def integration_phase
      run_single_stage :integrate
      run_single_stage :integrate_with_delay
    rescue => e  # don't rollback
      Card::Error.current = e
      @card.notable_exception_raised
      return false
    end

    def catch_up_to_stage next_stage
      @stage ||= -1
      (@stage + 1).upto(stage_index(next_stage)) do |i|
        run_single_stage stage_symbol(i)
      end
    end

    def call_after_store &block
      @call_after_store ||= []
      @call_after_store << block
    end

    def need_act
      act_director = main_director
      unless act_director
        raise Card::Error, 'act requested without a main stage director'
      end
      act_director.act ||= Card::Act.create(ip_address: Env.ip)
      @card.current_act = @act = act_director.act
    end

    def main_director
      if main?
        self
      else
        DirectorRegister.act_director || (@parent && @parent.main_director)
      end
    end

    def to_s
      str = @card.name.to_s.clone
      if @subdirectors
        subs = subdirectors.map(&:card)
                 .map { |card| "  #{card.name}" }.join "\n"
        str << "\n#{subs}"
      end
      str
    end

    private

    def run_single_stage stage, &block
      # puts "#{@card.name}: #{stage} stage".red
      @stage = stage_index stage
      return if @card.errors.any? && @stage <= stage_index(:validate)
      if stage == :initialize
        @running ||= true
        prepare_for_phases
      end
      # in the store stage it can be necessary that
      # other subcards must be saved before we save this card
      if stage == :store
        store(&block)
      else
        run_stage_callbacks stage
        run_subdirector_stages stage unless stage == :finalize
      end
    rescue => e
      @card.rescue_event e
    end

    def run_stage_callbacks stage
      # we use abort :success in the :store stage for :save_draft
      if stage_index(stage) <= stage_index(:store) && !main?
        @card.abortable do
          @card.run_callbacks :"#{stage}_stage"
        end
      else
        @card.run_callbacks :"#{stage}_stage"
      end
    end

    def run_subdirector_stages stage
      @subdirectors.each do |subdir|
        subdir.catch_up_to_stage stage
      end
    ensure
      @card.handle_subcard_errors
    end

    # handle the store stage
    # The tricky part here is to preserve the dirty marks on the subcards'
    # attributes for the finalize stage.
    # To achieve this we can't just call the :store and :finlaize callbacks on
    # the subcards as  we do in the other phases.
    # Instead we have to call `save` on the subcards
    # and use the ActiveRecord :around_save callback to run the :store and
    # :finalize stages
    def store &save_block
      if main? && !block_given?
        raise Card::Error, 'need block to store main card'
      end
      # the block is the ActiveRecord block from the around save callback that
      # saves the card
      if block_given?
        run_stage_callbacks :store
        store_with_subcards(&save_block)
      else
        store_and_finalize_as_subcard
      end
    end

    def store_with_subcards
      store_prior_subcards
      yield
      if @call_after_store
        @call_after_store.each do |handle_id|
          handle_id.call(@card.id)
        end
      end
      store_subcards
      @virtual = false # TODO: find a better place for this
    ensure
      @card.handle_subcard_errors
    end

    # store subcards whose ids we need for this card
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

    # trigger the storage_phase, skip the other phases
    # At this point the :prepare_to_store stage was already executed
    # by the parent director. So the storage phase will only run
    # the :store stage and the :finalize stage
    def store_and_finalize_as_subcard
      @card.skip_phases = true
      @card.save! validate: false
    end
  end

  class StageSubdirector < StageDirector
    def initialize card, opts={}
      super card, opts, false
    end

    def delete
      @parent.subdirectors.delete self if @parent
      super
    end
  end
end
