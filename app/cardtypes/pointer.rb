module Card
	class Pointer < Base
	  
	  def pointees
	    links = out_references.plot :referenced_name
	    links.empty? ? [''] : links
	  end
	  
	end
end