module Wagn::Cardname   
  CARD_KEYS = {}
  require 'htmlentities'

  JOINT = '+'
#JOINT=Cardname::JOINT
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
    junction? && !!(tag_name =~ /\*default|\*content/)
  end
  
  def email_config_name?
    junction? && ["*subject","*message"].include?(tag_name)
  end
  
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
    simple? ? [self] : ([self] + left_name.piece_names + tag_name.piece_names).uniq
  end
  
  def particle_names
    split(JOINT)
  end
  
  def left_name
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
    decode_html.gsub(/[^\*\w\s\+]/,' ').strip.gsub(/[\s\_]+/,'_')
  end
  
  def to_key
    split(JOINT).map do |name|  
      CARD_KEYS[name] ||= name.decode_html.underscore.gsub(/[^\w\*]+/,'_').split(/_+/).plot(:singularize).reject {|x| x==""}.join("_")
    end.join(JOINT)
  end
  
  def decode_html
    if self.match(/\&/)
      coder = HTMLEntities.new
      coder.decode(self)
    else
      self
    end
  end

  def css_name
    self.to_key.gsub('*','X').gsub('+','-')
  end

  def to_show(absolute)
    (self =~/\b_(left|right|whole|self|user|\d+|L*R?)\b/) ? absolute : self
  end

  def to_star
    (self=~/^\*/) ? self : '*'+self
  end
  
  def to_absolute(context_name)
    context_parts = context_name && context_name.split(JOINT)
    # split wont give an item after trailing +
    # we add a space to force it
    (self+" ").split(JOINT).map do |part|
      new_part = case part.strip
        when /^_user$/i;  (user=User.current_user) ? user.cardname : part
        when /^(_self|_whole|_)$/i; context_name
        when /^_left$/i;            context_name.trunk_name
        when /^_right$/i;           context_name.tag_name
        when /^_(\d+)$/i;           context_parts[ $~[1].to_i - 1 ] 
        when /^_(L*)(R?)$/i
          l_count, r_count = $~[1].size, $~[2].size
          trunk = context_name.split(JOINT)[0..(0-(l_count+1))].join(JOINT)
          r_count > 0 ? trunk.tag_name : trunk
        else                     part
      end
      new_part = (new_part || "").strip
      new_part.empty? ? context_name : new_part
    end.join(JOINT)
  end
  def append_features(base)
    String.include Wagn::Cardname::ClassMethods
  end
end    
               
# pollute the main namespace because we use it sooo much

class String
end
