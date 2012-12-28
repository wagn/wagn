# -*- encoding : utf-8 -*-

class Card < ActiveRecord::Base
  class Reference < ActiveRecord::Base
  end

  module ReferenceTypes
    LINK    = 'L'
    INCLUDE = 'T'

    TYPES   = [ LINK, INCLUDE ]
  end

  class Reference

    include ReferenceTypes

    def referencer
      Card[card_id]
    end

    def referencee
      Card[referenced_card_id]
    end

    validates_inclusion_of :link_type, :in => ReferenceTypes::TYPES

    class << self
      include ReferenceTypes

      def update_on_create card
        where( "link_type IN ('L' 'M') and (referenced_card_id = ? or referenced_name = ?)", card.id, name ).
          update_all :link_type => 'L', :referenced_card_id => card.id
        where( "link_type IN ('T' 'W') and (referenced_card_id = ? or referenced_name = ?)", card.id, name ).
          update_all :link_type => 'T', :referenced_card_id => card.id
      end

      def update_on_destroy card, name=nil
        name ||= card.key
        delete_all :card_id => card.id

        where( "link_type IN ('L' 'M') and (referenced_card_id = ? or referenced_name = ?)", card.id, name ).
          update_all :link_type => 'M', :referenced_card_id => nil
        where( "link_type IN ('T' 'W') and (referenced_card_id = ? or referenced_name = ?)", card.id, name ).
          update_all :link_type => 'W', :referenced_card_id => nil
      end
    end

  end
end
