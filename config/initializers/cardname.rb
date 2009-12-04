module Cardname   
  CARD_KEYS = {}

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
  
  def template_name?
    tag_name.=~ /\*.form$/
  end
=begin      
  def auto_template_name
    (simple? ? self : self.tag_name) + "+*template"
  end
=end
    
  def replace_part( oldpart, newpart )
    part_names(oldpart.particle_names.size).map {|x| x.to_key == oldpart.to_key ? newpart : x }.join("+")
  end
  
  def part_names(n=1)
    p = particle_names
    size > 1 ? [p[0..(n-1)].join(JOINT), p[n..p.size]].flatten.compact : p
  end

  def pre_cgi
    gsub('+','~plus~')
  end
  
  def post_cgi
    gsub('~plus~','+')
  end
    
  def piece_names
    simple? ? [self] : ([self] + parent_name.piece_names + tag_name.piece_names).uniq
  end
  
  def particle_names
    split(JOINT)
  end
  
  def parent_name
    simple? ? nil : trunk_name
  end

  def trunk_name
    split(JOINT)[0..-2].join(JOINT)
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
  
  def to_url_key
    gsub(/[^\*\w\s\+]/,' ').strip.gsub(/[\s\_]+/,'_')
  end
  
  def to_key
    split(JOINT).map do |name| 
      CARD_KEYS[name] ||= name.underscore.split(/[^a-z0-9\*]+/).plot(:singularize).reject {|x| x==""}.join("_")
    end.join(JOINT)
  end  

  def to_show(absolute)
    (self =~/_(left|right|whole|self|user)/) ? absolute : self
  end

  def to_star
    (self=~/^\*/) ? self : '*'+self
  end
  
  def to_absolute(context_name)
    name = self
    name.gsub! /_self|_whole/  , context_name
    name.gsub! /\s*\+$/        , '+'+context_name 
    name.gsub! /^\+\s*/        , context_name+'+' 
    if context_name.junction?  
      name.gsub! /_left/       , context_name.parent_name
      name.gsub! /_right/      , context_name.tag_name
#      name.sub!  /_(\-?\d+)/ , context_name.particle_names[$~[1].to_i]  #fixme -- this would break on multiple nums
    else
      name.gsub! /_left|_right/, context_name
    end
    name
  end

end    
               
# pollute the main namespace because we use it sooo much
JOINT=Cardname::JOINT

class String
  include Cardname
end