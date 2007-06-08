require_dependency "acts_as_proxy"
require_dependency 'acts_as_card_extension'

# in order for observers to work right, we need to load up all the 
# card subclasses here, except the ones generated on the fly, which 
# have the observers copied in.
require_dependency 'card/base'
require_dependency 'card/basic'
require_dependency 'card/cardtype'
require_dependency 'card/role'
require_dependency 'card/user'
require_dependency 'wql'
    
# Hack to get ActiveRecord to load dynamic Cardtype-- otherwise it throws the
# "SubclassNotFound" error when loading the card object.
module ActiveRecord
  class Base
    def compute_type(type_name)
      warn "LOOKING FOR #{type_name}"
      modularized_name = type_name_with_module(type_name)
      begin
        if match_data = modularized_name.match(/^Card::(\w+)$/)
          Card.const_get(match_data[1])
        end
        instance_eval(modularized_name)
      rescue NameError => e
        instance_eval(type_name)
      end
    end
  end
end

module Card
    mattr_reader :default_datatype_key
    @@default_datatype_key = "RichText"  
    
    mattr_reader :default_plus_datatype_key
    @@default_plus_datatype_key = "RichText"  

    mattr_reader :default_cardtype_key
    @@default_cardtype_key = "Basic"

  class << self

    def method_missing( method_id, *args )
      Card::Base.send(method_id, *args)
    end
   
    def create( args={} )
      cardtype = ( v = args.pull(:cardtype)) ? v : 'Basic'
      Card.const_get( cardtype ).create( args )
    end      

    def create!( args={} )
      cardtype = ( v = args.pull(:cardtype)) ? v : 'Basic'
      Card.const_get( cardtype ).create!( args )
    end      
    
    # FIXME -- the current system of caching cardtypes is not "thread safe":
    # multiple running ruby servers could get out of sync re: available cardtypes  
    
    def cardtypes
      @cardtypes or load_cardtypes!
    end
  
    # FIXME-- probably want to cache this instead of hitting db every time
    def const_missing( class_id )
      super
    rescue NameError => e
      if cardtypes.has_key?( class_id.to_s )
        newclass = Class.new( Card::Basic )
        const_set class_id, newclass
        Card::Base.instance_variable_get('@observer_peers').each do |o|
          newclass.add_observer(o)
        end
        return newclass
      else
        raise e
      end
    end
        
    private
      def load_cardtypes!
        @cardtypes = ::Cardtype.find(:all).inject({}) do |hash,ct|
          hash[ct.class_name] = true; hash
        end
      end
    
  end
end
