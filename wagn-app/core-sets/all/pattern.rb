# -*- encoding : utf-8 -*-
MODULES={}


module ClassMethods
  def method_key opts
    set_patterns.each do |pclass|
      if !pclass.opt_keys.map(&opts.method(:has_key?)).member? false;
        return pclass.method_key_from_opts(opts)
      end
    end
  end

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

  def find_set_model_module mod
    module_name_parts = mod.split('::')
    module_name_parts.inject Wagn::Set do |base, part|
      return if base.nil?
      #Rails.logger.warn "find m #{base}, #{part}"
      part = part.camelize
      key = "#{base}::#{part}"
      if MODULES.has_key?(key)
        MODULES[key]
      else
        args = Card::RUBY18 ? [part] : [part, false]
        MODULES[key] = base.const_defined?(*args) ? base.const_get(*args) : nil
      end
    end
  rescue Exception => e
  #rescue NameError => e
    Rails.logger.warn "find_set_model_module error #{mod}: #{e.inspect}"
    return nil if NameError ===e
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

def safe_keys
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
