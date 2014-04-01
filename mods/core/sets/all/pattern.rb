MODULES={}

module ClassMethods

  def find_set_pattern mark
    if mark
      class_key = if Card::Name === mark
        key_card = Card.fetch mark.to_name.tag_name, :skip_modules=>true
        key_card && key_card.codename
      else
        mark.to_s
      end
      set_patterns.find { |sub| sub.key == class_key }
    end
  end

end


def patterns
  @patterns ||= set_patterns.map { |sub| sub.new(self) }.compact
end

def patterns_with_new
  new_card? ? patterns_without_new[1..-1] : patterns_without_new
end
alias_method_chain :patterns, :new

def reset_patterns
  @set_mods_loaded = @patterns = @set_modules = @junction_only = @method_keys = @set_names = @template = @rule_set_keys = @virtual = nil
  true
end

def reset_patterns_if_rule saving=false
  if !new_card? && is_rule?
    set = left
    set.reset_patterns
    set.include_set_modules

    #this is really messy.
    if saving
      self.add_to_read_rule_update_queue( set.item_cards :limit=>0 ) if right.id == Card::ReadID
    end
  end
end

def safe_set_keys
  patterns.map( &:safe_key ).reverse * " "
end

def set_modules
  @set_modules ||= patterns_without_new[0..-2].reverse.map(&:set_const).compact
end

def set_names
  if @set_names.nil?
    @set_names = patterns.map &:to_s
    Card.set_members @set_names, key
  end
  @set_names
end

def rule_set_keys
  set_names #this triggers set_members cache.  need better solution!
  @rule_set_keys ||= patterns.map( &:rule_set_key ).compact
end

def method_keys
  @method_keys ||= patterns.map(&:get_method_key).compact
end
