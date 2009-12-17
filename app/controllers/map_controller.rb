class MapController < ActionController::Base
  def show
    @content = ""
    done = []
    cards = Card.all(:include => :current_revision, 
      :conditions => "name LIKE '%+related patterns'")
    cards.each do |card|
      name = card.name.sub(/\+related patterns$/,'')
      card.current_revision.content.scan(/\[\[([^\]]*)\]\]/) do |related|
        @content += name+"~->~"+related[0]+"\n"
        done.push(name);
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
end
