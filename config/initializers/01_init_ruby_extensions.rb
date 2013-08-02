# -*- encoding : utf-8 -*-
RUBY_VERSION_18 = !!(RUBY_VERSION =~ /^1\.8/)

class Hash

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

end

class Object
  # FIXME: move this, mixin, don't extend Object
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

  def send_unless method, *args, &block
    ( block_given? ? yield : self ) or  send method, *args
  end

  def send_if     method, *args, &block
    ( block_given? ? yield : self ) and send method, *args
  end
  
  def to_name
    Card::Name.new self
  end
end

class String
  def to_html
    split(/\n/).map {|line| "<p>#{line.strip.empty? ? '&nbsp;' : line}</p>"} * "\n"
  end
end

class Module
  def const_get_if_defined const
    args = RUBY_VERSION_18 ? [ const ] : [ const, false ]
    if const_defined? *args
      const_get *args
    end
  end
  
  def const_get_or_set const
    const_get_if_defined const or const_set const, yield
  end
end

