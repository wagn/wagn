module Cardname   

  JOINT = '+'
  CARDNAME_BANNED_CHARACTERS = [ JOINT, '_', '/', '~', '|']

  class << self
    def escape(uri)
      #gsub(/\s+\+\s+/,'+')
      uri.gsub(' ','_').gsub('+',' ')
    end

    def unescape(uri)
      uri.gsub(' ','+').gsub('_',' ')
    end

  end
    def valid_cardname?
    split(JOINT).each do |name|
      return false unless name.match(/^([^#{"\\"+CARDNAME_BANNED_CHARACTERS.join("\\")}])*$/)
    end
    return true
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

end    

# pollute the main namespace because we use it sooo much
JOINT=Cardname::JOINT

class String
  include Cardname
end