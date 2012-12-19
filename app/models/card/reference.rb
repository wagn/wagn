# -*- encoding : utf-8 -*-

class Card < ActiveRecord::Base
  class Reference < ActiveRecord::Base
  end

  module ReferenceTypes
      LINK = 'L'
      WANTED_LINK = 'W'
      INCLUSION = 'T'
      WANTED_INCLUSION = 'M'
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

  def self.cards_that_link_to(card_name)
    self.find_cards_by_reference_name_and_type_list(card_name, LINK, WANTED_LINK)
  end

  def self.cards_that_include(card_name)
    self.find_cards_by_reference_name_and_type_list(card_name, INCLUSION, WANTED_INCLUSION)
  end

  class << self
    include Card::ReferenceTypes
    def update_on_create( card )
      Rails.logger.warn "update on create #{card.inspect} #{where(:referenced_name=>card.key).map(&:to_s)*', '}"
      where(:referenced_name=>card.key, :link_type=>WANTED_LINK).update_all(:link_type => LINK);
      where(:referenced_name=>card.key, :link_type=>WANTED_INCLUSION).update_all(:link_type => INCLUSION);
      Rails.logger.warn "updated on create #{card.inspect} #{where(:referenced_name=>card.key).map(&:to_s)*', '}"
    end

    def update_on_destroy( card, name=nil )
      Rails.logger.warn "update on dest #{card.inspect}, #{caller[0,20]*", "}"
      key = name.nil? ? card.key : name.to_name.key
      delete_all ['card_id = ?', card.id]
      where( '(referenced_name = ? or referenced_card_id = ?) and link_type=?', key, card.id, LINK ).
        update_all :link_type => WANTED_LINK, :referenced_card_id=>nil
      where( '(referenced_name = ? or referenced_card_id = ?) and link_type=?', key, card.id, INCLUSION ).
        update_all :link_type => WANTED_INCLUSION, :referenced_card_id=>nil
    end
  end

end
