
class Card
  class StageDirector
    include Stage

    attr_accessor :subcards, :prior_store, :act, :card, :stage, :parent, :main

    def initialize card, opts={}, main=true
      @card = card
      @card.director = self
      @card.prepare_for_phases
      @stage = nil
      @running = false
      @parent = opts[:parent]
      # Has card to be stored before the supercard?
      @prior_store = opts[:priority]
      @main = main
      @subdirectors = []
      card.subcards.each_card do |subcard|
        add_subdirector subcard
      end
      register
    end

    def register
      Card::DirectorRegister.add self
    end

    def unregister
      @card.director = nil
      @subdirectors = nil
      @stage = nil
      @action = nil
      Card::DirectorRegister.delete self
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
      catch_up_to_stage :prepare_to_store
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

    def running?
      @running
    end

    def add_subdirector card
      @subdirectors.each do |subdir|
        return subdir if subdir.card == card
      end
      subdir = Card::DirectorRegister.fetch card, parent: self
      subdir.main = false
      subdir.parent = self
      @subdirectors << subdir
      subdir
    end

    def delete_subdirector card
      @subdirectors.delete_if { |subdir| subdir.card == card }
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
      if !act_director
        fail Card::Error, 'act requested without a main stage director'
      end
      act_director.act ||=  Card::Act.create(ip_address: Env.ip)
      @card.current_act = @act = act_director.act
    end

    def main_director
      if main?
        self
      else
        DirectorRegister.act_director || (@parent && @parent.main_director)
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

    def run_single_stage stage, &block
      # puts "#{@card.name}: #{stage} stage".red
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

    def run_stage_callbacks stage
      if stage_index(stage) <= stage_index(:validate)
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

    def store_and_finalize_as_subcard
      @card.skip_phases = true
      #catch_up_to_stage :store
      @card.save! validate: false #
    end
  end

  class StageSubdirector < StageDirector
    def initialize card, opts={}
      super card, opts, false
    end
  end
end