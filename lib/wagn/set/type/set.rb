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

  def reset_set_patterns
    (list = Card.members(key).map{|name| Card[name]}.compact).each(&:reset_patterns)
    #warn Rails.logger.warn("reset_sp #{name}, #{list.inspect}")
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
    #warn "ptr? #{tag.id || cardname.tag} && #{trunk.id || cardname.trunk}" if junction? and !new_card?
    pointer_test = if type_id == Card::SetID and
            templt = existing_trait_card(:content) || existing_trait_card(:default)
          templt.type_id
        elsif !new_card? && junction?
        #elsif !new_card? && junction? and tg = tag || Card[cardname.tag] and
        tg = tag || Card[cardname.tag]
        tk = trunk || Card[cardname.trunk]
        raise "missing tk #{cardname.trunk}" unless tk
        raise "missing tg #{cardname.tag}" unless tg
          case tg.id
            when Card::TypeID; tk.id
            when Card::SelfID; tk.type_id
          end
        end
    #warn "ptr tst #{self.inspect} :: #{templt.inspect}, #{self.tag_id}, #{junction? && "#{trunk.inspect} + #{tag.inspect}"}, #{pointer_test}"
    #Rails.logger.debug "setting_names_by_group #{cardname.to_s}, #{cardname.tag_name.to_s}, #{pointer_test}"

    groups[:pointer] = ['*options','*options label','*input'] if pointer_test==Card::PointerID
    groups
  end

end
