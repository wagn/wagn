# ok, this one is just going to use the whole system to do the migration,
# and if the system changes, the migration will break.  I don't see an easy
# way to isolate this one.

class TildeToPlus < ActiveRecord::Migration
  def self.up
    Card.find(:all, :conditions=>["trunk_id IS NOT NULL"]).each do |card|
      oldname = card.name
		if oldname =~ /\~/
      	card.update_attribute(:name, card.title_tag_names.join(JOINT))
      	raise "BUSTED" if oldname==card.name
      	puts "renaming #{oldname} to #{card.name}"
      	card.linkers.each do |linker|
        		WagBot.instance.revise_card_links( linker, oldname, card.name )
      	end
		end
    end
    
  end

  def self.down
    # whatcha gonna do?
  end
end
