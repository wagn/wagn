# -*- encoding : utf-8 -*-

class Card::Reference < ActiveRecord::Base
  include Wagn::ReferenceTypes
  belongs_to :referencer, :class_name=>'Card', :foreign_key=>'card_id'
  belongs_to :referencee, :class_name=>'Card', :foreign_key=>"referenced_card_id"

  validates_inclusion_of :link_type, :in => REF_TYPES

  def self.cards_that_reference name
    where( :link_type => REF_TYPES,        :referenced_name=>name ).collect &:referencer
  end

  def self.cards_that_link_to name
    where( :link_type => LINK_TYPES,       :referenced_name=>name ).collect &:referencer
  end

  def self.cards_that_transclude name
    where( :link_type => TRANSCLUDE_TYPES, :referenced_name=>name ).collect &:referencer
  end

  class << self
    include Wagn::ReferenceTypes

    def update_on_create card
      where( :link_type=>LINK_TYPES.last,         :referenced_name => card.key ).
        update_all :link_type => LINK_TYPES.first,       :referenced_card_id => card.id

      where( :link_type => TRANSCLUDE_TYPES.last, :referenced_name => card.key ).
        update_all :link_type => TRANSCLUDE_TYPES.first, :referenced_card_id => card.id
    end

    def update_on_destroy card, name=nil
      name ||= card.key
      delete_all :card_id => card.id

      where( :link_type => LINK_TYPES.first,        :referenced_card_id=>card.id, :referenced_name => name ).
        update_all :link_type=>LINK_TYPES.last,       :referenced_card_id => nil

      where( :link_type => TRANSCLUDE_TYPES.first, :referenced_card_id=>card.id, :referenced_name => name ).
        update_all :link_type=>TRANSCLUDE_TYPES.last, :referenced_card_id => nil
    end
  end

end
