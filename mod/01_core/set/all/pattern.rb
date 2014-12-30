
def patterns
  @patterns ||= set_patterns.map { |sub| sub.new(self) }.compact
end

def patterns_with_new
  new_card? ? patterns_without_new[1..-1] : patterns_without_new
end
alias_method_chain :patterns, :new

def reset_patterns
  @set_mods_loaded = @patterns = @set_modules = @junction_only = @set_names = @template = @rule_set_keys = @virtual = nil
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
  @set_modules ||= patterns_without_new[0..-2].reverse.map(&:module_list).flatten.compact
end

def set_format_modules klass
  @set_format_modules ||= {}
  @set_format_modules[klass] = patterns_without_new[0..-2].reverse.map do |pattern|
    pattern.format_module_list klass
  end.flatten.compact
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

