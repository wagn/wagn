class Hash
  def pull(key)
    has_key?(key) && !(v = delete(key)).to_s.empty? ? v : false
  end    

  # FIXME: ? damn, this is ugly.  use JSON instead?
  class << self
    def new_from_semicolon_attr_list(attr_string)
      return {} if attr_string.blank?
      attr_string.split(';').inject({}) do |result, pair|
        value, key = pair.split(':').reverse
        key ||= 'view'
        key.strip!; value.strip!
        result[key.to_sym] = value
        result
      end
    end      
  end
  
  def to_semicolon_attr_list
    self.map {|key,value| key.to_s == 'view' ? value : "#{key}:#{value}" }.join(";")
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