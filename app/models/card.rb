require_dependency 'acts_as_card_extension'

# FIXME: this is here because errors defined in permissions break without it? kinda dumb
module Card    
  class CardError < Wagn::Error   
    attr_reader :card
    def initialize(card)
      @card = card
      super build_message 
    end    
    
    def build_message
      "#{@card.name} has errors: #{@card.errors.full_messages.join(', ')}"
    end
  end
end
  

require 'json'
require_dependency 'card/base' 
require_dependency 'card/tracked_attributes'
require_dependency 'card/templating'
require_dependency 'card/defaults' 
require_dependency 'card/permissions'
require_dependency 'card/search'
require_dependency 'card/references'
require_dependency 'card/caching'

Card::Base.class_eval do       
  include CardLib::TrackedAttributes
  include CardLib::Templating
  include CardLib::Defaults
  include CardLib::Permissions                               
  include CardLib::Search 
  include CardLib::References
  #include CardLib::Caching 
end
 

Dir["#{RAILS_ROOT}/app/cardtypes/*.rb"].sort.each do |cardtype|
  cardtype.gsub!(/.*\/([^\/]*)$/, '\1')
  begin
    require_dependency "cardtypes/#{cardtype}"
  rescue Exception=>e
    raise "Error loading cardtypes/#{cardtype}: #{e.message}"
  end
end
   
    
# Hack to get ActiveRecord to load dynamic Cardtype-- otherwise it throws the
# "SubclassNotFound" error when loading the card object. 
#
# FIXME: should check if this is still necessary-- the relevant rails code
#  looks different now
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

class HardTemplate
  def self.find(*args)
  end
end

class SoftTemplate
  def self.find(*args)
  end
end

module Card    
  mattr_reader :default_cardtype_key
  @@default_cardtype_key = "Basic"

  class << self
    def new(args={})
      args=args.stringify_keys unless args.nil?
      get_class_from_args(args).new(args)
    end
    
    def method_missing( method_id, *args )
      Card::Base.send(method_id, *args)
    end  
         
    def create_these( definitions ) 
      definitions.each do |key, content|
        type, name = (key =~ /\:/ ? key.split(':') : ['Basic',key])
        Card.const_get(type).create! :name=>name, :content=>content
      end
    end
    
    def const_missing( class_id )
      super
    rescue NameError => e   
      ::Cardtype.load_cache if ::Cardtype.cache.empty?
      if ::Cardtype.cache[:card_names].has_key?( class_id.to_s )
        newclass = Class.new( Card::Basic )
        const_set class_id, newclass
        # FIXME: is this necessary?
        if observers = Card::Base.instance_variable_get('@observer_peers')
          observers.each do |o|
            newclass.add_observer(o)
          end
        end
        return newclass
      else
        raise e
      end
    end
        
  end
end
