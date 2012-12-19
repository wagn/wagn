# -*- encoding : utf-8 -*-

class Card < ActiveRecord::Base
  class Reference < ActiveRecord::Base
  end

  module ReferenceTypes

    LINK    = 'L'
    INCLUDE = 'T'

    TYPES   = [ LINK, INCLUDE ]
  end
end

class Card::Reference

  include Card::ReferenceTypes

  belongs_to :referencer, :class_name=>'Card', :foreign_key=>'card_id'
  belongs_to :referencee, :class_name=>'Card', :foreign_key=>"referenced_card_id"

  validates_inclusion_of :link_type, :in => [  LINK, WANTED_LINK, INCLUSION, WANTED_INCLUSION ]

  def self.find_cards_by_reference_name_and_type_list(card_name, *type_list)
    sql_list = "'" + type_list.join("','") + "'"
    self.find( :all, :conditions=>[%{
      link_type in (#{sql_list}) and referenced_name=?
    },card_name]).collect {|ref| ref.referencer }
  end

  def self.cards_that_reference(card_name)
    self.find_cards_by_reference_name_and_type_list( card_name, LINK, WANTED_LINK, INCLUSION, WANTED_INCLUSION )
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
