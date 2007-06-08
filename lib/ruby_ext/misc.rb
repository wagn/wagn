class Hash
  def pull(key)
    has_key?(key) && !(v = delete(key)).to_s.empty? ? v : false
  end    

  # FIXME: ? damn, this is ugly.  use JSON instead?
  class << self
    def new_from_semicolon_attr_list(attr_string)
      return {} if attr_string.blank?
      attr_string.split(';').inject({}) do |result, pair|
        key, value = pair.split(':') 
        key.strip!; value.strip!
        result[key.to_sym] = value
        result
      end
    end      
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
end