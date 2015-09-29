# -*- encoding : utf-8 -*-
require_dependency 'card/env'

require 'smart_name'

class Card
  class Name < SmartName

    self.params  = Card::Env # yuck!
    self.session = proc { Card::Auth.current.name }
    self.banned_array = ['/']

    def star?
      simple? and '*' == s[0,1]
    end

    def rstar?
      right and '*' == right[0,1]
    end

    def trait_name? *traitlist
      junction? && begin
        right_key = right_name.key
        !!traitlist.find do |codename|
          card_id = Card::Codename[ codename ] and card = Card.fetch( card_id, skip_modules: true, skip_virtual: true ) and
            card.key == right_key
        end
      end
    end

    def trait_name tag_code
      card_id = Card::Codename[ tag_code ] and card = Card.fetch( card_id, skip_modules: true, skip_virtual: true ) and
        [ self, card.cardname ].to_name
    end

    def trait tag_code
      name = trait_name( tag_code )
      name ? name.s : ( raise Card::NotFound, "unknown codename: #{tag_code}" )
    end

    def field tag_name
      field_name( tag_name).s
    end

    def code
      Card::Codename[ Card.fetch_id self ]
    end

    def field_name tag_name
      case tag_name
      when Symbol
        trait_name tag_name
      else
        [ self, tag_name ].to_name
      end
    end

    def relative_field_name tag_name
      field_name(tag_name).relative_name(self)
    end

    def relative_name context_name
      self.to_show(*context_name.to_name.parts).to_name
    end

    def absolute_name context_name
      self.to_absolute_name(context_name)
    end

    def is_a_field_of? context_name
      if context_name.present?
        # Do I still equal myself after I've been relativised in the context of context_name?
        relative_name(context_name).key != absolute_name(context_name).key
      else
        self.s.match /^\s*\+/
      end
    end

    def is_setting?
      Set::Type::Setting.member_names[ key ]
    end

    def is_set?
      SetPattern.card_keys[ tag_name.key ]
    end
  end
end
