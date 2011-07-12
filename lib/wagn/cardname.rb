module Wagn::Cardname
  class << self
    def escape(uri)
      #gsub(/\s+\+\s+/,'+')
      uri.gsub(' ','_') #.gsub('+',' ')  This was making for ugly urls.  does it actually fix anything??  -- efm
    end
  
    def unescape(uri)
      uri.gsub(' ','+').gsub('_',' ')
    end    
  end
end 
