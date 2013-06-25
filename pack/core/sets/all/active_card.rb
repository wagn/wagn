# -*- encoding : utf-8 -*-

def card_attributes
  if Card::Set.traits
    set_modules.each do |mod|
      if mod_traits = Card::Set.traits[mod]
        return mod_traits
      end
    end
  end
  nil
end

def trait_var? var_name
  !instance_variable_get( var_name ).nil?
end

def trait_var var_name, &block
 r =
  instance_variable_get( var_name ) ||
    instance_variable_set( var_name, block_given? ? yield : '' )
#warn "get trait_var #{var_name}: #{r.inspect}"; r
end

event :save_card_attributes, :after => :store, :on => :save do
  return true unless attributes = card_attributes
Rails.logger.warn "card attrs #{attributes.inspect}"
  attributes.keys.each do |trait_name|
    card_attr = "@#{trait_name}_card"
    if trait_var? card_attr
      trait_card = trait_var(card_attr)
Rails.logger.warn "tn saving #{trait_name}, #{trait_card.inspect}, #{trait_card.content}"
      trait_card.save
      instance_variable_set card_attr, nil
      instance_variable_set "@#{trait_name}", nil
      
      #trait_var(card_attr).save
Rails.logger.warn "tn saved #{trait_name}, #{card_attr.inspect}, #{trait_var? card_attr}, #{trait_var card_attr}"
    end
  end
  true
end
