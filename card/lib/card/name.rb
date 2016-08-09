# -*- encoding : utf-8 -*-
require_dependency "card/env"

require "smart_name"

class Card
  class Name < SmartName
    RELATIVE_REGEXP = /\b_(left|right|whole|self|user|main|\d+|L*R?)\b/

    self.params  = Card::Env # yuck!
    self.session = proc { Card::Auth.current.name }
    self.banned_array = ["/"]

    def star?
      simple? && "*" == s[0, 1]
    end

    def rstar?
      right && "*" == right[0, 1]
    end

    def trait_name? *traitlist
      junction? && begin
        right_key = right_name.key
        traitlist.find do |codename|
          (card_id = Card::Codename[codename]) &&
            (card = Card.quick_fetch card_id) &&
            card.key == right_key
        end.present?
      end
    end

    def trait_name tag_code
      (card_id = Card::Codename[tag_code]) &&
        (card = Card.quick_fetch card_id) &&
        [self, card.cardname].to_name
    end

    def trait tag_code
      name = trait_name(tag_code)
      name ? name.s : (raise Card::NotFound, "unknown codename: #{tag_code}")
    end

    def field tag_name
      field_name(tag_name).s
    end

    def code
      Card::Codename[Card.fetch_id self]
    end

    # returns full name for a field
    def field_name tag_name
      case tag_name
      when Symbol
        trait_name tag_name
      else
        tag_name = tag_name.to_s[1..-1] if tag_name.to_s[0] == "+"
        [self, tag_name].to_name
      end
    end

    def relative_field_name tag_name
      field_name(tag_name).relative_name(self)
    end

    def relative_name context_name
      to_show(*context_name.to_name.parts).to_name
    end

    def absolute_name context_name
      to_absolute_name(context_name)
    end

    def child_of? context_name
      if context_name.present?
        # Do I still equal myself after I've been relativised in the context
        # of context_name?
        relative_name(context_name).key != absolute_name(context_name).key
      else
        s.match(/^\s*\+/)
      end
    end

    def field_of? context_name
      if context_name.present?
        child_of?(context_name) && relative_name(context_name).length == 2
      else
        s.match(/^\s*\+[^+]+$/)
      end
    end

    def setting?
      Set::Type::Setting.member_names[key]
    end

    def set?
      SetPattern.card_keys[tag_name.key]
    end

    def relative?
      s =~ RELATIVE_REGEXP || starts_with_joint?
    end

    def absolute?
      !relative?
    end

    def stripped
      s.gsub RELATIVE_REGEXP, ""
    end

    def starts_with_joint?
      s =~ /^\+/
    end

    def to_sym
      s.to_sym
    end
  end
end
