# -*- encoding : utf-8 -*-

class Card
 
  module ReferenceTypes

    LINK       = [ 'L', 'W' ]
    TRANSCLUDE = [ 'T', 'M' ]

    TYPES      = [ *LINK,  *TRANSCLUDE]

    TYPE_MAP = {
      Chunk::Link       => { false => LINK.first,       true => LINK.last       },
      Chunk::Transclude => { false => TRANSCLUDE.first, true => TRANSCLUDE.last },
    }

  end


  class Reference < ActiveRecord::Base
    belongs_to :referencer, :class_name=>'Card', :foreign_key=>'card_id'
    belongs_to :referencee, :class_name=>'Card', :foreign_key=>"referenced_card_id"

    validates_inclusion_of :link_type, :in => ReferenceTypes::TYPES

    class << self
      include ReferenceTypes

      def cards_that_reference name
        where( :link_type => TYPES,        :referenced_name=>name ).collect &:referencer
      end

      def cards_that_link_to name
        where( :link_type => LINK,       :referenced_name=>name ).collect &:referencer
      end

      def cards_that_transclude name
        where( :link_type => TRANSCLUDE, :referenced_name=>name ).collect &:referencer
      end

      def update_on_create card
        Rails.logger.debug "u create #{card.inspect}"
        where( :link_type=>LINK.last,         :referenced_name => card.key ).
          update_all :link_type => LINK.first,       :referenced_card_id => card.id

        where( :link_type => TRANSCLUDE.last, :referenced_name => card.key ).
          update_all :link_type => TRANSCLUDE.first, :referenced_card_id => card.id
      end

      def update_on_destroy card, name=nil
        Rails.logger.debug "u dest #{card.inspect}, N:#{name}"
        name ||= card.key
        delete_all :card_id => card.id

        where( :link_type => LINK.first,        :referenced_card_id=>card.id, :referenced_name => name ).
          update_all :link_type=>LINK.last,       :referenced_card_id => nil

        where( :link_type => TRANSCLUDE.first, :referenced_card_id=>card.id, :referenced_name => name ).
          update_all :link_type=>TRANSCLUDE.last, :referenced_card_id => nil
      end
    end

  end
end
