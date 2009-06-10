module Card
	class Pointer < Base

    class << self
      def options_card(tagname)
        card = ::User.as(:wagbot) do
	        CachedCard.get_real("#{tagname}+*options")
	      end
	      card.type=='Search' ? card : nil
	    end
	    
    end

	  def cacheable?
      false
    end
	  
	  def pointees
	    links = content.split(/\n+/).map{ |x| x.gsub(/\[\[|\]\]/,'')}
	    links.empty? ? [''] : links
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