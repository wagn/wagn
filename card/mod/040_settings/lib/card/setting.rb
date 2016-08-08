# -*- encoding : utf-8 -*-

class Card
  # Used to extend setting modules like Card::Set::Self::Create in the
  # settings mod
  module Setting
    # Let M = Card::Setting           (module)
    #     E = Card::Set::Self::Create (module extended with M)
    #     O = Card['*create']         (object)
    # accessible in E
    attr_accessor :codename
    # accessible in E and M
    mattr_accessor :groups, :group_names, :user_specific
    def self.extended host_class
      # accessible in E and O
      host_class.mattr_accessor :restricted_to_type, :rule_type_editable
    end

    @@group_names = {
      templating:  "Templating",
      permission:  "Permissions",
      webpage:     "Webpage",
      pointer:     "Pointer",
      editing_cue: "Editing cues",
      event:       "Events",
      other:       "Other",
      config:      "Config"
    }
    @@groups = @@group_names.keys.each_with_object({}) do |key, groups|
      groups[key] = []
    end
    @@user_specific = ::Set.new

    def self.user_specific? codename
      @@user_specific.include? codename
    end

    def to_type_id type
      type.is_a?(Fixnum) ? type : Card::Codename[type]
    end

    # usage:
    # setting_opts group:        :permission | :event | ...
    #              position:     <Fixnum> (starting at 1, default: add to end)
    #              rule_type_editable: true | false (default: false)
    #              restricted_to_type: <cardtype> | [ <cardtype>, ...]
    def setting_opts opts
      group = opts[:group] || :other
      @@groups[group] ||= []
      set_position group, opts[:position]

      @codename = opts[:codename] ||
                  name.match(/::(\w+)$/)[1].underscore.to_sym
      self.rule_type_editable = opts[:rule_type_editable]
      self.restricted_to_type =
        if opts[:restricted_to_type]
          type_ids = [opts[:restricted_to_type]].flatten.map do |cardtype|
            to_type_id(cardtype)
          end
          ::Set.new(type_ids)
        end
      return unless opts[:user_specific]
      @@user_specific << @codename
    end

    def set_position group, pos
      if pos
        if @@groups[group][pos - 1]
          @@groups[group].insert(pos - 1, self)
        else
          @@groups[group][pos - 1] = self
        end
      else
        @@groups[group] << self
      end
    end

    def applies_to_cardtype type_id
      !restricted_to_type || restricted_to_type.include?(type_id)
    end
  end
end
