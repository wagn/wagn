


# Broken Card Names
cards = [] #..
broken = cards.select{|c| c.name_from_parts != c.name }; broken.length
broken.each_with_index {|c,i| puts "#{i}: #{c.name} -> #{c.name_from_parts}";  c.name_without_tracking=c.name_from_parts; c.save!; }; ''