# encoding: utf-8
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
    when Fixnum,Bignum,Float,NilClass,FalseClass,TrueClass,Symbol
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
