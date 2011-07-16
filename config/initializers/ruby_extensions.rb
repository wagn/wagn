class Hash
  def pull(key)
    has_key?(key) && !(v = delete(key)).to_s.empty? ? v : false
  end    

  # FIXME: ? damn, this is ugly.  use JSON instead?
  class << self
    def new_from_semicolon_attr_list(attr_string)
      return {} if attr_string.blank?
      attr_string.strip.split(';').inject({}) do |result, pair|
        value, key = pair.split(':').reverse
        key ||= 'view'
        key.strip!; value.strip!
        result[key.to_sym] = value
        result
      end
    end      
  end
  
  def to_semicolon_attr_list
    self.map {|key,value| key.to_s == 'view' ? value : "#{key}:#{value}" }.sort_by(&:length).join(";")
  end

end


module Enumerable
  # instead of objects.map {|x| x.foo(blah)} 
  # do objects.plot(:foo,blah)
  def plot(method_name, *args)
    map do |o|
      o.send(method_name, *args)
    end
  end
  
end

class Class
  def descendents
    raise "descendents is deprecated: it's too slow.  find another way"
    descendents = []
    ObjectSpace.each_object(Class) do |klass|
      descendents << klass if klass.ancestors.include?(self)
    end
    descendents
  end
end

class String 
  def substitute!( hash )
    hash.keys.each do |var|
      self.gsub!(/\{(#{var})\}/) {|x| hash[var.to_sym]}
    end
    self
  end   
  
  def to_codename
    self.gsub(/\s+/,'_').underscore
  end  
  
  def wrap!(before, after)
    self.insert(0,before)
    self.insert(-1,after)
    self
  end
end            

class Array
  def except(*exceptions)
    result = self.clone
    result.delete_if { |i| exceptions.include?(i) }
    result
  end
  def except!(*exceptions)
    self.delete_if { |i| exceptions.include?(i) }
    self
  end
  def each_except(*exceptions)
    self.each do |i|
      if exceptions.include?(i) == false
        yield(i)
      end
    end
  end
end

class Object
  def deep_clone
    case self
    when Fixnum,Bignum,Float,NilClass,FalseClass,TrueClass,Continuation,Symbol
      klone = self
    when Hash
      klone = self.clone
      self.each{|k,v| klone[k] = v.deep_clone}
    when Array
      klone = self.clone
      klone.clear
      self.each{|v| klone << v.deep_clone}
    else
      klone = self.clone
    end
    klone.instance_variables.each {|v|
      klone.instance_variable_set(v,
      klone.instance_variable_get(v).deep_clone)
    }
    klone
  end
  
  def m
    time = Benchmark.measure { yield }
    sprintf("%.2f",time.real * 1000) + 'ms'
  end
  
end

#module Wagn::Cardname   
# pollute the main namespace because we use it sooo much
class String
  CARD_KEYS = {}
  require 'htmlentities'
  
  JOINT = '+'
  #JOINT=Cardname::JOINT
  CARDNAME_BANNED_CHARACTERS = [ JOINT, '/', '~', '|']
  
  FORMAL_JOINT = " <span class=\"wiki-joint\">#{JOINT}</span> "   
  
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
  
  def module_name
    self.gsub(/^\*/,'X_').gsub(/[\b\s]+/,'_').camelcase
  end
  
  def css_name
    self.to_key.gsub('*','X').gsub('+','-')
  end
  
  def to_show(absolute)
    (self =~/\b_(left|right|whole|self|user|\d+|L*R?)\b/) ? absolute : self
  end
  
  def to_star
    star? ? self : '*'+self
  end
  
  def star?
    !!(self=~/^\*/)
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
end    

