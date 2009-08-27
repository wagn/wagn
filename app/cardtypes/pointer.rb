module Card
	class Pointer < Base

    class << self
      def options_card(tagname)
        card = ::User.as(:wagbot) do
	        CachedCard.get_real("#{tagname}+*options")
	      end
	      (card && card.type=='Search') ? card : nil
	    end
    end

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
	    
	  def pointees=(items)
	    self.content = [items].flatten.map{|x| "[[#{x}]]"}.join("\n")
    end  
    
    def pointee=(item)
      self.pointees = [item]
    end  
	  
	  def item_type
	    opt = options_card
	    opt ? opt.get_spec[:type] : nil
	  end
	  
	  def options_card
	    return nil unless tag
	    self.class.options_card(tag.name)
	  end
	end
end