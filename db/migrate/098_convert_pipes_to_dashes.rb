class ConvertPipesToDashes < ActiveRecord::Migration
  def self.up
    #FIXME -- I can't find a way to match a stinking pipe.
    # the following might work in postgres, in which case we'd be ok for the real need, but it breaks in mysql.
    
    cards = [] #Card.find_by_wql("cards with name ~ '|'")
    cards.each do |c| 
      c.name = c.name.gsub('|', '-')
      c.save!
    end
  end

  def self.down
  end
end
