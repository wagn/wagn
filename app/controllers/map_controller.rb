class MapController < ActionController::Base
  def show
    @content = ""
    done = []
    cards = Card.all(:include => :current_revision, 
      :conditions => "name LIKE '%+related patterns'")
    cards.each do |card|
      name = card.name.sub(/\+related patterns$/,'')
      done.push(name);
      card.current_revision.content.scan(/\[\[([^\]]*)\]\]/) do |related|
        @content += name+"~->~"+related[0]+"\n"
        done.push(related[0])
      end
    end
    cards = Card.find_all_by_type("Pattern")
    cards.each do |card|
      name = card.name
      if (!done.include?(name))
        @content += name+"\n"
      end
    end
  end
  
  
#  def show
#    content, done = [], {}
#    Card.search(:type=>'Pattern', :plus_right=>'related patterns').each do |linker|
#      Card.search(:type=>'Pattern', :linked_to_by=>{:id=>linker.id}).each do |linkee|
#        content<< "#{linker.name}~->~#{linkee.name}"
#        [linker, linkee].each{|pattern| done[pattern.name]=true}
#      end
#    end
#    Card.search(:type=>'Pattern').each do |pattern|
#      done[pattern.name] or content<<pattern.name}
#    end
#    @content = content.join("\n")
#  end
end
