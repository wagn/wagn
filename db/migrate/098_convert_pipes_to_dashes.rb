class ConvertPipesToDashes < ActiveRecord::Migration
  def self.up

=begin
    #FIXME -- I can't find a way to match a stinking pipe.
    # the following might work in postgres, in which case we'd be ok for the real need, but it brea    
    cards = [] #Card.find_by_wql("cards with name ~ '|'")
    cards.each_with_index do |c,i| 
      puts "#{i}: #{c.name}"
      c.name = c.name.gsub('|', '-')
      c.save!
    end        
=end

    # this is the code i used to convert meyer

    cards = Card.find_by_sql(
    "SELECT DISTINCT  t0.* FROM cards t0  WHERE (t0.trash='f' AND t0.name LIKE '%'||E'|'||'%')"
    ) 
    cards=[]
    cards.each_with_index do |c,i| 
      oldname=c.name; c.name = c.name.gsub('|', '-'); puts "#{i} #{oldname}->#{c.name}"; 
      c.confirm_rename=true; c.update_link_ins=true; begin c.save!; rescue Exception=>e; puts e.message; end; 
    end


  end

  def self.down
  end
end
