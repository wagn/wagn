module Wagn::Set::Type::Set
  include Wagn::Set::Type::SearchType

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
    Card.members( key ).each do |mem|
      Card.expire mem
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

    raise "#setting_names_by_group called on non-set" if type_id != Card::SetID
    
    member_type_id = 
      if templt = existing_trait_card(:content) || existing_trait_card(:default)
        templt.type_id
      elsif junction?
        method = case right.id #this is the set class
          when Card::TypeID; :id
          when Card::SelfID; :type_id
          end
        left.send method if method
      end

    groups[:pointer] = ['*options','*options label','*input'] if member_type_id==Card::PointerID
    groups
  end

end
