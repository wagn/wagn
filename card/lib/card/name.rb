# -*- encoding : utf-8 -*-
require_dependency "card/env"

require "smart_name"

class Card
  # The SmartName class provides generalized of Card naming patterns
  # (compound names, key-based variants, etc)
  #
  # Card::Name adds support for deeper card integration
  class Name < SmartName
    include FieldsAndTraits
    include ::Card::Name::NameVariants

    self.params  = Card::Env # yuck!
    self.session = proc { Card::Auth.current.name }
    self.banned_array = ["/"]

    class << self
      def cardish mark
        case mark
        when Card            then mark.cardname
        when Symbol, Integer then Card.quick_fetch(mark).cardname
        else                      mark.to_name
        end
      end

      def url_key_to_standard key
        key.to_s.tr "_", " "
      end
    end

    def star?
      simple? && "*" == s[0, 1]
    end

    def rstar?
      right && "*" == right[0, 1]
    end

    def code
      Card::Codename[Card.fetch_id self]
    end

    def setting?
      Set::Type::Setting.member_names[key]
    end

    def set?
      Set::Pattern.card_keys[tag_name.key]
    end

    # processes contextual title argument used in nests like "title: _left"
    def title title_directive, context_names
      title_directive.to_name.to_absolute_name(self).to_show(*context_names)
    end
  end
end
