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
          card_id = Card::Codename[ codename ] and card = Card.fetch( card_id, :skip_modules=>true, :skip_virtual=>true ) and
            card.key == right_key
        end
      end
    end

    def trait_name tag_code
      card_id = Card::Codename[ tag_code ] and card = Card.fetch( card_id, :skip_modules=>true, :skip_virtual=>true ) and
        [ self, card.cardname ].to_name
    end

    def trait tag_code
      name = trait_name( tag_code )
      name ? name.s : ( raise Card::NotFound, "unknown codename: #{tag_code}" )
    end
    
    def code
      Card::Codename[ Card.fetch_id self ]
    end
  end
end
