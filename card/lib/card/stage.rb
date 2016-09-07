class Card
  # The process of writing a card change to the database is divided into
  # 8 stages that are grouped in 3 phases.
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
  module Stage
    STAGES = [:initialize, :prepare_to_validate, :validate, :prepare_to_store,
              :store, :finalize, :integrate, :integrate_with_delay].freeze
    STAGE_INDEX = {}
    STAGES.each_with_index do |stage, i|
      STAGE_INDEX[stage] = i
    end
    STAGE_INDEX.freeze

    def stage_symbol index
      case index
      when Symbol
        return index if STAGE_INDEX[index]
      when Integer
        return STAGES[index] if index < STAGES.size
      end
      raise Card::Error, "not a valid stage index: #{index}"
    end

    def stage_index stage
      case stage
      when Symbol then
        return STAGE_INDEX[stage]
      when Integer then
        return stage
      else
        raise Card::Error, "not a valid stage: #{stage}"
      end
    end

    def stage_ok? opts
      stage && (
      (opts[:during] && in?(opts[:during])) ||
        (opts[:before] && before?(opts[:before])) ||
        (opts[:after] && after?(opts[:after])) ||
        true # no phase restriction in opts
      )
    end

    def before? allowed_phase
      STAGE_INDEX[allowed_phase] > STAGE_INDEX[stage]
    end

    def after? allowed_phase
      STAGE_INDEX[allowed_phase] < STAGE_INDEX[stage]
    end

    def in? allowed_phase
      (allowed_phase.is_a?(Array) && allowed_phase.include?(stage)) ||
        allowed_phase == stage
    end
  end
end
