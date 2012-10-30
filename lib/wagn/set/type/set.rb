module Wagn::Set::Type::Set
  include Wagn::Set::Type::SearchType

  def inheritable?
    return true if junction_only?
    cardname.junction?
  end

  def subclass_for_set
    #FIXME - use codename??
    Wagn::Model::Pattern.subclasses.find do |sub|
      cardname.tag==sub.key_name
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
    if klass = subclass_for_set
      klass.label cardname.left
    else
      ''
    end
  end

  def prototype
    opts = subclass_for_set.prototype_args(self.cardname.trunk_name)
    Card.fetch_or_new opts[:name], opts
  end

end
