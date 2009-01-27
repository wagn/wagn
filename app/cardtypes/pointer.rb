module Card
	class Pointer < Base

=begin	  
	  def cacheable?
      false
    end
=end
	  
	  def pointees
	    links = content.split(/\n+/).map{ |x| x.gsub(/\[\[|\]\]/,'')}
	    links.empty? ? [''] : links
	  end
	  
	end
end