module ReferenceTypes
  unless defined? LINK
    LINK = 'L'
    WANTED_LINK = 'W'
    TRANSCLUSION = 'T'
    WANTED_TRANSCLUSION = 'M'
  end
end  


class WikiReference < ActiveRecord::Base
  include ReferenceTypes
  belongs_to :referencer, :class_name=>'Card::Base', :foreign_key=>'card_id'
  belongs_to :referencee, :class_name=>'Card::Base', :foreign_key=>"referenced_card_id"
  
  validates_inclusion_of :link_type, :in => [  LINK, WANTED_LINK, TRANSCLUSION, WANTED_TRANSCLUSION ]

  def self.find_cards_by_reference_name_and_type_list(card_name, *type_list)
    sql_list = "'" + type_list.join("','") + "'"
    self.find( :all, :conditions=>[%{
      link_type in (#{sql_list}) and referenced_name=?
    },card_name]).collect {|ref| ref.referencer }
  end
  
  def self.cards_that_reference(card_name)
    self.find_cards_by_reference_name_and_type_list( card_name, LINK, WANTED_LINK, TRANSCLUSION, WANTED_TRANSCLUSION )
  end

  def self.cards_that_link_to(card_name)
    self.find_cards_by_reference_name_and_type_list(card_name, LINK, WANTED_LINK)
  end

  def self.cards_that_transclude(card_name)
    self.find_cards_by_reference_name_and_type_list(card_name, TRANSCLUSION, WANTED_TRANSCLUSION)
  end

  class << self
    include ReferenceTypes
    def update_on_create( card )
      update_all("link_type = '#{LINK}', referenced_card_id=#{card.id}",  ['referenced_name = ? and link_type=?', card.key, WANTED_LINK])
      update_all("link_type = '#{TRANSCLUSION}', referenced_card_id=#{card.id}",  ['referenced_name = ? and link_type=?', card.key, WANTED_TRANSCLUSION])
    end
    
    def update_on_destroy( card, name=nil )   
      name ||= card.key
      delete_all ['card_id = ?', card.id]
      update_all("link_type = '#{WANTED_LINK}',referenced_card_id=NULL",  ['(referenced_name = ? or referenced_card_id = ?) and link_type=?', name, card.id, LINK])
      update_all("link_type = '#{WANTED_TRANSCLUSION}',referenced_card_id=NULL",  ['(referenced_name = ? or referenced_card_id = ?) and link_type=?', name, card.id, TRANSCLUSION])
    end
  end
  
end
