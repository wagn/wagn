class Revision < ActiveRecord::Base
  belongs_to :card, :class_name=>"Card::Base", :foreign_key=>'card_id'
  belongs_to :created_by, :class_name=>"User", :foreign_key=>"created_by"
  
  def author() created_by; end
    
  def author=(author)
    self.created_by=author
  end
  
  def title
    current_id = card.current_revision.id
    if id == current_id
      'Current Revision'
    elsif id > current_id
      'AutoSave'
    else
      card.revisions.each_with_index do |rev, index|
         return "Revision ##{index + 1}"  if rev.id == id
      end
    end
  end
  
end
