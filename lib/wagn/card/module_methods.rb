module Wagn::Card
 module ModuleMethods    

  def create_these( *args )                                                                                  
    definitions = args.size > 1 ? args : (args.first.inject([]) {|a,p| a.push({p.first=>p.last}); a })
    definitions.map do |input|
      final_args = {}
      input.each do |key, content|
        type, name = (key =~ /\:/ ? key.split(':') : ['Basic',key])   
        final_args.merge! :name=>name, :type=>type, :content=>content
      end         
      Card.create! final_args
    end
  end

  def valid_constant?(candidate)
    begin
      Card.const_defined?( candidate )
    rescue Exception => e
      return false
    end
    true
  end

=begin
  def card_const_set(class_id)
    newclass = Class.new( Card::Basic )
    const_set class_id, newclass
    # FIXME: is this necessary?
    if observers = Card.instance_variable_get('@observer_peers')
      observers.each do |o|
        newclass.add_observer(o)
      end
    end
    newclass
  end

  def const_missing( class_id )
    super
  rescue NameError => e   
    ::Cardtype.load_cache if ::Cardtype.cache.empty?
    classnames = ::Cardtype.cache[:card_names]
    raise e unless (classnames.has_key?( class_id.to_s ) and klass = card_const_set(class_id))
    klass
  end
=end
   
  def generate_codename_for(cardname)
    codename = cardname.gsub(/^\W+|\W+$/,'').gsub(/\W+/,'_').camelize   
    base, i = codename, 1
    while codename_unavailable?(codename)  
      codename = base+i.to_s
      i+=1
    end
    codename
  end
  
  def codename_unavailable?(name)
    const_defined?(name) || Module.const_get(name)
  rescue
    false
  end
   
  def default_typecode_key
    "Basic"
  end
 end
end    

=begin
Card.extend Wagn::Card::ModuleMethods

class HardTemplate
def self.find(*args)
end
end

class SoftTemplate
def self.find(*args)
end
end
=end
