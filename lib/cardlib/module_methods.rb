module Cardlib
  module ModuleMethods    
    def new(args={})
      args=args.stringify_keys unless args.nil?   
      p = Proc.new {|k| k.new(args)}
      c=with_class_from_args(args,p)  
    
      # autoname.  note I'm not sure that this is the right place for this at all, but 
      #  :set_needed_defaults returns if new_record? so I think we don't want it in there
      if !args.nil? and args["name"].blank?
        ::User.as(:wagbot) do
          if autoname_card = c.setting_card('autoname')
            c.name = autoname_card.content
            autoname_card.content = autoname_card.content.next
            autoname_card.save!
          end                                         
        end
      end
      c.send(:set_needed_defaults)
      c
    end 
  
    def method_missing( method_id, *args )
      Card::Base.send(method_id, *args)
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
