
def is_template?
  cardname.trait_name? :structure, :default
end

def is_structure?
  cardname.trait_name? :structure
end

def template
  # currently applicable templating card.
  # note that a *default template is never returned for an existing card.
  @template ||= begin
    @virtual = false

    if new_card?
      new_card_template
    else
      structure_rule_card
    end
  end
end

def new_card_template
  default = rule_card :default, skip_modules: true

  dup_card = dup
  dup_card.type_id = default ? default.type_id : Card.default_type_id

  if (structure = dup_card.structure_rule_card)
    @virtual = true if junction?
    self.type_id = structure.type_id if assign_type_to?(structure)
    structure
  else
    default
  end
end

def assign_type_to? structure
  return if type_id == structure.type_id
  structure.assigns_type?
end

def assigns_type?
  # needed because not all *structure templates govern the type of set members
  # for example, X+*type+*structure governs all cards of type X,
  # but the content rule does not (in fact cannot) have the type X.
  return unless (set_pattern = Card.fetch cardname.trunk_name.tag_name,
                                          skip_modules: true)
  return unless (pattern_code = set_pattern.codename)
  return unless (set_class = Card::SetPattern.find pattern_code)
  set_class.assigns_type
end

def structure
  return unless template && template.is_structure?
  template
end

def virtual?
  return false unless new_card?
  if @virtual.nil?
    cardname.simple? ? (@virtual = false) : template
  end
  @virtual
end

def structure_rule_card
  card = rule_card :structure, skip_modules: true
  card && card.db_content.strip == "_self" ? nil : card
end
