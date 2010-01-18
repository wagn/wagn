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

    
    def class_for(given_type)
      if ::Cardtype.name_for_key?( given_type.to_key )
        given_type = ::Cardtype.classname_for( ::Cardtype.name_for_key( given_type.to_key ))
      end
      
      begin 
        Card.const_get(given_type)
      rescue Exception=>e
        nil
      end
    end
    
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
     
    def generate_codename_for(cardname)
      class_name = cardname.gsub(/^\W+|\W+$/,'').gsub(/\W+/,'_').camelize   
      # shoot me now  
      if const_defined?(class_name)
        class_name_base, i = class_name, 1
        while const_defined?(class_name)  
          class_name = class_name_base + i.to_s
          i+=1
        end
      end
      class_name
    end
     
    def default_cardtype_key
      "Basic"
    end
  end    
end

Card.extend Cardlib::ModuleMethods

class HardTemplate
  def self.find(*args)
  end
end

class SoftTemplate
  def self.find(*args)
  end
end
