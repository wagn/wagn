# -*- encoding : utf-8 -*-

class Card
 
  module ReferenceTypes

    LINK    = 'L'
    INCLUDE = 'T'

    TYPES   = [ LINK, INCLUDE ]
  end


  class Reference < ActiveRecord::Base
    def referencer
      Card[referer_id]
    end

    def referencee
      Card[referee_id]
    end

    validates_inclusion_of :link_type, :in => ReferenceTypes::TYPES

    class << self
      include ReferenceTypes

      def update_on_create card
        where( :referee_key => card.key ).
          update_all :present => 1, :referee_id => card.id
      end

      def update_on_destroy card, name=nil
        name ||= card.key
        delete_all :referer_id => card.id

        where( "referee_id = ? or referee_key = ?", card.id, name ).
          update_all :present=>0, :referee_id => nil
      end
    end

  end
end
