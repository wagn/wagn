module Attributer
  DEFAULT_CONTENT=%q{dbl-click to edit}
  class << self
    def add_attribute_to_type(type,attr)
      Card.find_all_by_type(type).each do |card|
        puts "adding #{attr} to #{card.name}"
        add_attribute(card, attr)
      end
      true
    end
    
    def add_attribute( card, attr ) 
      c = Card::Base.find_or_create("#{card.name}+#{attr}", :content=>DEFAULT_CONTENT)
      if c.content.gsub(/<br>/,'') =~ /^\s*$/
        c.content = DEFAULT_CONTENT
        c.save
      end
    end
        
    def remove_dummy_attributes( card, attr )
      Card.find(:all).each do |card|  
        if card.content==DEFAULT_CONTENT
          card.destroy
        end
      end
    end
  end
end  
