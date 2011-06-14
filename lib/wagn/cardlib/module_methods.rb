module Wagn
 module Cardlib
  module ModuleMethods    
    # create, and create! copied from activerecord.
    # make sure we call Card.new  before dropping to 
    # Card::X.create,new,etc., so we can do class lookup, defaults, etc.
    # in Card.new
    # def create(attributes = nil, &block)
    #   if attributes.is_a?(Array)
    #     attributes.collect { |attr| create(attr, &block) }
    #   else
    #     object = new(attributes)
    #     yield(object) if block_given?
    #     object.save
    #     object
    #   end
    # end
    # 
    # def create!(attributes = nil, &block)
    #   if attributes.is_a?(Array)
    #     attributes.collect { |attr| create!(attr, &block) }
    #   else
    #     object = new(attributes)
    #     yield(object) if block_given?
    #     object.save!
    #     object
    #   end
    # end

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
     
    def default_cardtype_key
      "Basic"
    end
  end    
 end
end

Card.extend Wagn::Cardlib::ModuleMethods

class HardTemplate
  def self.find(*args)
  end
end

class SoftTemplate
  def self.find(*args)
  end
end
