event :save_recently_edited_settings, :integrate,
      on: :save, when: proc { |c| c.is_rule? } do
  if (recent = Card[:recent_settings])
    recent.insert_item 0, cardname.right
    recent.save
  end
end

def rule_set_key
  rule_set_name.key
end

def rule_set_name
  if is_preference?
    cardname.trunk_name.trunk_name
  else
    cardname.trunk_name
  end
end

def rule_set
  if is_preference?
    self[0..-3]
  else
    trunk
  end
end

def rule_setting_name
  cardname.tag
end

def rule_setting_title
  rule_setting_name.tr "*", ""
end

def rule_user_setting_name
  if is_preference?
    "#{rule_user_name}+#{rule_setting_name}"
  else
    rule_setting_name
  end
end

def rule_user_name
  is_preference? ? cardname.trunk_name.tag : nil
end

def rule_user
  is_preference? ? self[-2] : nil
end

# ~~~~~~~~~~ determine the set options to which a user can apply the rule.
def set_options
  candidates = set_prototypes.set_names
  first = first_set_option_index candidates
  tally = { existing: 0, options: [] }
  candidates[first..-1].each do |set_name|
    tally_set_option set_name, tally
  end
  tally[:options]
end

def tally_set_option set_name, tally
  state =
    if Card.exists?("#{set_name}+#{rule_user_setting_name}")
      tally[:existing] += 1
      tally[:existing] == 1 ? :current : :overwritten
    else
      tally[:existing] < 1 ? :enabled : :disabled
    end
  tally[:options] << [set_name, state]
end

# the narrowest rule should be the one attached to the set being viewed.
# So, eg, if you're looking at the '*all plus' set, you shouldn't
# have the option to create rules based on arbitrary narrower sets, though
# narrower sets will always apply to whatever prototype we create
def first_set_option_index candidates
  new_card? ? 0 : candidates.index { |c| c.to_name.key == rule_set_key }
end

def set_prototype
  if is_preference?
    self[0..-3].prototype
  else
    trunk.prototype
  end
end
