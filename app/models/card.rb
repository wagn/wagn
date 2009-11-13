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
require 'uuid'

Card::Base.class_eval do   
  Cardlib:AttributeTracking    
  include Cardlib::TrackedAttributes
  include Cardlib::Templating
  include Cardlib::Defaults
  include Cardlib::Permissions                               
  include Cardlib::Search 
  include Cardlib::References  
  include Cardlib::Cacheable      
  include Cardlib::Settings
  extend Card::CardAttachment::ActMethods
  
end



Notification.init

Dir["#{RAILS_ROOT}/app/models/card/*.rb"].sort.each do |cardtype|
  cardtype.gsub!(/.*\/([^\/]*)$/, '\1')
  begin
    require_dependency "card/#{cardtype}"
  rescue Exception=>e
    raise "Error loading card/#{cardtype}: #{e.message}"
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
      p = Proc.new {|k| k.new(args)}
      c=with_class_from_args(args,p)  
      
      # autoname.  note I'm not sure that this is the right place for this at all, but 
      #  :set_needed_defaults returns if new_record? so I think we don't want it in there
      if args["name"].blank?
        ::User.as(:wagbot) do
          autoname_cardname = ::Cardtype.name_for(c.type)+"+*autoname" 
          if CachedCard.get_real autoname_cardname
            autoname_card = Card[autoname_cardname]
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
     
  end
end    

#FIXME: this should be at a more coherent stage of the process.
# we have to rescue errors because it sometimes is run before the database structure is in place
# which triggers errors.
begin
  %w{ *head *alert *foot *navbox *version *account_link }.each do |key|
    Card.add_builtin( Card.new(:name=>key, :builtin=>true))
  end
rescue
end


