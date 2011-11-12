module Wagn::Set::Type::Set
  include Wagn::Set::Type::Search

  def setting_names_by_group
    groups = Card.universal_setting_names_by_group.clone
    # Generalize Me!
    pointer_test = (
      (templt = (Card[name+'+*content'] || Card[name+'+*default']) and
                 templt.typecode) or case cardname.tag_name.to_s
                   when '*type'; cardname.trunk_name
                   when '*self'; tk=Card[cardname.trunk_name] and tk.typecode
                   end).to_s
    #Rails.logger.debug "setting_names_by_group #{cardname.to_s}, #{cardname.tag_name.to_s}, #{pointer_test}"

    groups[:pointer] = ['*options','*options label','*input'] if pointer_test=='Pointer'
    groups
  end

end
