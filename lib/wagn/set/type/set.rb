module Wagn::Set::Type::Set
  include Wagn::Set::Type::Search
  
  def setting_names_by_group
    groups = Card.universal_setting_names_by_group.clone
    # Generalize Me!
    pointer_test = case cardname.tag_name
      when '*type'; cardname.trunk_name
      when /right/; tmpl=(Card["#{name}+*content".to_cardname] || Card["#{name}+*default".to_cardname]) and tmpl.typecode
      when '*self'; tmpl=Card[cardname.trunk_name] and tmpl.typecode
      else; false
      end
      
    groups[:edit] += ['*options','*options label','*input'] if pointer_test=='Pointer'
    groups
  end
  
end
