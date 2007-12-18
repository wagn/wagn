module Cardname   

  JOINT = '+'
  CARDNAME_BANNED_CHARACTERS = [ JOINT, '/', '~', '|']

  FORMAL_JOINT = " <span class=\"wiki-joint\">#{JOINT}</span> "   

  class << self
    def escape(uri)
      #gsub(/\s+\+\s+/,'+')
      uri.gsub(' ','_') #.gsub('+',' ')  This was making for ugly urls.  does it actually fix anything??  -- efm
    end

    def unescape(uri)
      uri.gsub(' ','+').gsub('_',' ')
    end

  end
  def valid_cardname?
    split(JOINT).each do |name|
      return false unless name.match(/^([^#{"\\"+CARDNAME_BANNED_CHARACTERS.join("\\")}])+$/)
    end
    return true
  end
      
  def auto_template_name
    (simple? ? self : self.tag_name) + "+*template"
  end
    
  def piece_names
    simple? ? [self] : ([self] + parent_name.piece_names + tag_name.piece_names).uniq
  end
  
  def parent_name
    simple? ? nil : split(JOINT)[0..-2].join(JOINT)
  end

  def tag_name  
    split(JOINT).pop
  end

  def simple?
    !include?(JOINT)
  end
  
  def junction?
    include?(JOINT)
  end  
  
  def to_key
    split(JOINT).map do |name| 
      name.underscore.split(/[^\w\*]+/).plot(:singularize).reject {|x| x==""}.join("_")
    end.join(JOINT)
  end  

end    
               
# pollute the main namespace because we use it sooo much
JOINT=Cardname::JOINT

class String
  include Cardname
end