
def patterns
  @patterns ||= set_patterns.map { |sub| sub.new self }.compact
end

def patterns_with_new
  new_card? ? patterns_without_new[1..-1] : patterns_without_new
end
alias_method_chain :patterns, :new

def reset_patterns
  @patterns = nil
  @template = @virtual = nil
  @set_mods_loaded = @set_modules = @set_names = @rule_set_keys = nil
  @junction_only = nil # only applies to set cards
  true
end

def reset_patterns_if_rule saving=false
  if !new_card? && is_rule?
    set = left
    set.reset_patterns
    set.include_set_modules

    # FIXME: should be in right/read.rb
    if saving && right.id == Card::ReadID
      add_to_read_rule_update_queue set.item_cards(limit: 0)
    end
  end
end

def safe_set_keys
  patterns.map(&:safe_key).reverse * " "
end

def set_modules
  @set_modules ||=
    patterns_without_new[0..-2].reverse.map(&:module_list).flatten.compact
end

def set_format_modules klass
  @set_format_modules ||= {}
  @set_format_modules[klass] =
    patterns_without_new[0..-2].reverse.map do |pattern|
      pattern.format_module_list klass
    end.flatten.compact
end

def set_names
  @set_names = patterns.map(&:to_s) if @set_names.nil?
  @set_names
end

def in_set? set_module
  patterns.map(&:module_key).include? set_module.shortname
end

def rule_set_keys
  @rule_set_keys ||= patterns.map(&:rule_set_key).compact
end
