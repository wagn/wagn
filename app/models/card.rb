module CardData
  def extract_plus_data!
    keys.inject({}) {|h,k| h[k] = delete(k) if k =~ /^\+/; h }
  end
end

module Card
  class << self
    def method_missing( method_id, *args )
      Card::Base.send(method_id, *args )
    end

    def [](arg)
      Card::Base[arg]
    end
    
    def class_for(name, field='codename')
      class_id = ( field.to_sym == :codename ? name :
          ( cardname = ::Cardtype.name_for_key(name.to_key) and
            ::Cardtype.classname_for(cardname) ) 
      )
      klass = Card.const_get(class_id)
      klass.allocate.is_a?(Card::Base) ? klass : card_const_set(class_id)
    rescue Exception=>e
      nil
    end
  end
end  

