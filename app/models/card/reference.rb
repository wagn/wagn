# -*- encoding : utf-8 -*-

class Card
 
  module ReferenceTypes

    LINK       = 'L'
    TRANSCLUDE = 'T'

    TYPES      = [ LINK, TRANSCLUDE ]
  end


  class Reference < ActiveRecord::Base
    def referencer
      Card[card_id]
    end

    def referencee
      Card[referenced_card_id]
    end

    def missing_referencee
      Card.fetch referenced_card_name
    end

    validates_inclusion_of :ref_type, :in => ReferenceTypes::TYPES

    class << self
      include ReferenceTypes

      def update_on_create card
        where( :referenced_name => card.key ).
          update_all :present => 1, :referenced_card_id => card.id
      end

      def update_on_destroy card, name=nil
        name ||= card.key
        delete_all :card_id => card.id

        where( "referenced_card_id = ? or referenced_name = ?", card.id, name ).
          update_all :present=>0, :referenced_card_id => nil
      end
    end

  end
end
