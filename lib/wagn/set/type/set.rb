module Wagn::Set::Type::Set
  include Wagn::Set::Type::Search
  
  def setting_names_by_group
    groups = Card.universal_setting_names_by_group.clone
    # Generalize Me!
    pointer_test = case name.tag_name
      when '*type'; name.trunk_name
      when /right/; tmpl=(Card["#{name}+*content"] || Card["#{name}+*default"]) and tmpl.typecode
      when '*self'; tmpl=Card[name.trunk_name] and tmpl.typecode
      else; false
      end
      
    groups[:editing] += ['*options','*options label','*input'] if pointer_test=='Pointer'
    groups
  end
  
end
