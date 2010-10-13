module Card
	class Pointer < Base

	  def cacheable?
      false
    end
	  	  
	  def add_reference( cardname )
	    unless pointees.include? cardname
	      self.content = (pointees + [cardname]).reject{|x|x.blank?}.map{|x| "[[#{x}]]" }.join("\n")
  	    save!
      end
    end 
	                                   
	  def remove_reference( cardname ) 
	    if pointees.include? cardname
  	    self.content = (pointees - [cardname]).map{|x| "[[#{x}]]"}.join("\n")
  	    save!
	    end
    end
	    
	  def option_text(option)
	    name = setting('option label') || 'description'
	    textcard = Card.fetch(option+'+'+name, :skip_virtual => true)
	    textcard ? textcard.content : nil
	  end
	    
	  def pointees=(items)
	    items=items.values if Hash===items 
	    self.content = [items].flatten.reject{|x|x.blank?}.map{|x| "[[#{x}]]"}.join("\n")
    end  
    
    def pointee=(item)
      self.pointees = [item]
    end  
	  
	  def item_type
	    opt = options_card
	    opt ? opt.get_spec[:type] : nil
	  end
	  
	  def options_card
      card = self.setting_card('options')
	    (card && card.type=='Search') ? card : nil
	  end
	  
	  def options(limit=50)
      (oc=self.options_card) ? oc.search(:limit=>limit) : Card.search(:sort=>'alpha',:limit=>limit)
    end
    
#    def autoname
#      System.setting("#{self.name.tag_name}+*autoname")
#    end
	end
end