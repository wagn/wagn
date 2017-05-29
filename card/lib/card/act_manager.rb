class Card
  # Manages the whole process of creating an {act Card::Act} ie. changing
  # a card and attached subcards.
  #
  # For every card that is part of the act the ActManager creates a
  # {StageDirector} that leads the card through all the stages.
  # Because cards sometimes get expired and reloaded during an act we need
  # this global object to ensure that the stage information doesn't get lost
  # until the act is finished.
  #
  # The process of creating an act/writing a card change to the database
  # is divided into 8 stages that are grouped in 3 phases.
  #
  # 'validation phase'
  #   * initialize stage (I)
  #   * prepare_to_validate stage (P2V)
  #   * validate stage (V)
  #
  # 'storage phase'
  #   * prepare_to_store stage (P2S)
  #   * store stage (S)
  #   * finalize stage (F)
  #
  # 'integration phase'
  #   * integrate stage (IG)
  #   * integrate_with_delay stage (IGwD)
  #
  #
  # The table below gives you an overview what you can do in which stage:
  #
  #                                  validation    |    storage    | integration
  #                                 I    P2V  V    |  P2S  S    F  | IG   IGwD
  #-------------------------------------------------------------------------
  #    attach subcard               yes! yes! yes  | yes  yes  yes |    yes
  #    detach subcard               yes! yes! yes  | yes  no   no! |    no!
  #    validate                     yes  yes  yes! |      no       |    no
  # 1  insecure change              yes  yes! no   |      no!      |    no!
  # 2  secure change                     yes       | yes! no!  no! |    no!
  #    abort                             yes!      |      yes      |    yes?
  #    add errors                        yes!      |      no!      |    no!
  # 3  create other cards                yes       |      yes      |    yes
  #    has id                            no        | no   no?  yes |    yes
  #    within web request                yes       |      yes      | yes  no
  # 4  within transaction                yes       |      yes      |    no

  #    available values:
  #    dirty attributes                  yes       |      yes      |    yes
  #    params                            yes       |      yes      |    yes
  #    success                           yes       |      yes      | yes  no
  #    session                           yes       |      yes      | yes  no
  #
  #
  # Explanation:
  #  yes!  the recommended stage to do that
  #  yes   ok to do it here
  #  no    not recommended; chance to mess things up
  #        but if something forces you to do it here you can try
  #  no!   never do it here. it won't work or will break things
  #
  # if there is only a single entry in a phase column it counts for all stages
  # of that phase
  #
  # 1) 'insecure' means a change of a card attribute that can possibly make
  #    the card invalid to save
  # 2) 'secure' means you are sure that the change doesn't affect the validation
  # 3) If you call 'create', 'update_attributes' or 'save' the card will become
  #    part of the same act and all stage of the validation and storage phase
  #    will be executed immediately for that card. The integration phase will be
  #    executed together with the act card and its subcards
  # 4) This means if an exception is raised in the validation or storage phase
  #    everything will rollback. If the integration phase fails the db changes
  #    of the other two phases will remain persistent.
  class ActManager
    cattr_accessor :act_card

    class << self
      def act_director
        return unless act_card
        act_card.director
      end

      def directors
        @directors ||= {}
      end

      def clear
        ActManager.act_card = nil
        directors.each_pair do |card, _dir|
          card.director = nil
        end
        @directors = nil
      end

      def fetch card, opts={}
        return directors[card] if directors[card]
        directors.each_key do |dir_card|
          return dir_card.director if dir_card.name == card.name
        end
        directors[card] = new_director card, opts
      end

      def include? name
        directors.keys.any? { |card| card.key == name.to_name.key }
      end

      def new_director card, opts={}
        if opts[:parent]
          StageSubdirector.new card, opts
        elsif act_card && act_card != card && running_act?
          act_card.director.subdirectors.add card
        else
          StageDirector.new card
        end
      end

      def add director
        # Rails.logger.debug "added: #{director.card.name}".green
        directors[director.card] = director
      end

      def card_changed old_card
        return unless (director = @directors.delete old_card)
        add director
      end

      def delete director
        return unless @directors
        @directors.delete director.card
        director.delete
      end

      def deep_delete director
        director.subdirectors.each do |subdir|
          deep_delete subdir
        end
        delete director
      end

      def running_act?
        (dir = act_director) && dir.running?
      end

      def to_s
        act_director.to_s
        #directors.values.map(&:to_s).join "\n"
      end
    end
  end
end
