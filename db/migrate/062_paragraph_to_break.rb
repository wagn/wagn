class ParagraphToBreak < ActiveRecord::Migration
  def self.up 
    Card.find(:all).collect {|card| card.current_revision }.each do |revision|
      revision.content.gsub!(/(<\/p>)/i,'\1<br/>')
      revision.save
    end
  end

  def self.down    
  end
end
