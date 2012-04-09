module Wagn::Set::Type::Set
  include Wagn::Set::Type::Search

  def inheritable?
    return true if junction_only?
    cardname.tag_name=='*self' && cardname.trunk_name.junction? 
  end

  def subclass_for_set
    Wagn::Model::Pattern.subclasses.find do |sub|
      cardname.tag_name.to_s==sub.key_name
    end
  end

  def junction_only?()
    !@junction_only.nil? ? @junction_only :
       @junction_only = subclass_for_set.junction_only
  end

  def reset_set_patterns(setting_card)
    # maybe we could only reset when the trait exists?
    read_rule = setting_card.nil? ? false : setting_card.id == Card::ReadID 
    #warn "reset_set_patterns(#{name}), #{setting_card&&setting_card.name}, RR:#{read_rule.inspect}"
    item_cards(:limit=>0).each do |member|
      #warn "RRRreset member #{member.name}"
      member.reset_patterns
      member.update_read_rule if read_rule
    end
  end

  def label
    return '' unless klass = subclass_for_set
    klass.label cardname.left_name.to_s
  end

  def prototype
    opts = subclass_for_set.prototype_args(self.cardname.trunk_name)
    Card.fetch_or_new opts[:name], opts
  end

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
