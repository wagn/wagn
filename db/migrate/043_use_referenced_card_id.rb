require_dependency 'db/card_creator.rb'

class UseReferencedCardId < ActiveRecord::Migration
  def self.up
    MWikiReference.find(:all, :conditions=>["referenced_card_id IS NULL"]).each do |ref|
      if c = MCard.find_by_name(ref.referenced_name)
        puts "updating ref to #{ref.referenced_name}"
        ref.update_attributes :referenced_card_id=>c.id
      end
    end
  end

  def self.down
  end
end
