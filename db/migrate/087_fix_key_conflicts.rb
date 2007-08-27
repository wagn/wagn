class FixKeyConflicts < ActiveRecord::Migration
  def self.up 
     User.as :admin
     puts "gathering conflicts"
     conflicts_by_key = Card.find_by_sql(%{
       select * from cards where key in 
       (select key from cards group by key having count(*) > 1) 
       order by name
     }).inject({}){|h,x| h[x.key]||=[]; h[x.key]<<x; h }
      
     puts "gathered conflicts"
     conflicts_by_key.each_pair do |key,cards| 
       c1, c2, c3, c4 = cards.sort{|a,b| a.in_references.length <=> b.in_references.length}
       print  "fixing #{key} : #{c1.type}:#{c1.name}, #{c2.type}:#{c2.name} .."
       if c1.name  =~ /\*/ 
         print "updating c1 key"
         c1.update_attributes! :key => c1.name.to_key
       elsif c2.name =~ /\*/
         print "updating c2 key"
         c2.update_attributes! :key => c2.name.to_key
       elsif (c2.type == 'Basic' and c1.type != 'Basic') or c1.type=='Cardtype'
         print "updating c2 #{c2.name} copy"
         c2.update_attributes(:name=> c2.name + " copy") or
           c2.update_attributes(:name=> c2.name + " copy 2") or
           c2.update_attributes!(:name=> c2.name + " copy 3")
       else
         print "updating c1 #{c1.name} copy"
         c1.update_attributes(:name=> c1.name + " copy") or
          c1.update_attributes(:name=> c1.name + " copy 2") or
          c1.update_attributes!(:name=> c1.name + " copy 3")
       end  
       puts  "..fixed"
     end  
            
     add_unique_index 'cards', 'key'
   rescue
  end

  def self.down
  end
end
