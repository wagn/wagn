module CardLib
  module Cacheable
    def hard_template?
      extension_type =='HardTemplate'
    end

    def soft_template?
      !hard_template?
    end

    # FIXME: pointees should
    # return [] instead of [''] in case none are found
    # but we're depending on that [''] api.
	  def pointees
	    User.as(:wagbot) do
  	    links = content.split(/\n+/).map{ |x| x.gsub(/\[\[|\]\]/,'')}
  	    links.empty? ? [''] : links
	    end
	  end

    def watchers
      watchers = []
      [ 
        CachedCard.get("#{name}+*watchers"), 
        CachedCard.get( ::Cardtype.name_for( self.type ) + "+*watchers" )
      ].compact.each do |c|
        watchers += c.pointees.reject{|x|x==''}
      end  
      watchers
    end

    
  end
end