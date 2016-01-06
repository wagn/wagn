event :save_recently_edited_settings,
      before: :extend, on: :save, when: proc { |c| c.is_rule? } do
  if (recent = Card[:recent_settings])
    recent.insert_item 0, cardname.right
    recent.save
  end
end

def rule_set_key
  rule_set_name.key
end

def rule_set_name
  if is_user_rule?
    cardname.trunk_name.trunk_name
  else
    cardname.trunk_name
  end
end

def rule_set
  if is_user_rule?
    self[0..-3]
  else
    trunk
  end
end

def rule_setting_name
  cardname.tag
end

def rule_user_setting_name
  if is_user_rule?
    "#{rule_user_name}+#{rule_setting_name}"
  else
    rule_setting_name
  end
end

def rule_user_name
  is_user_rule? ? cardname.trunk_name.tag : nil
end

def rule_user
  is_user_rule? ? self[-2] : nil
end

# ~~~~~~~~~~ determine the set options to which the user can apply the rule.
def set_options
  first = if new_card?
            0
          else
            set_prototype.set_names.index { |s| s.to_name.key == rule_set_key }
          end
  rule_cnt = 0
  res = []
  fallback_set = nil
  set_prototype.set_names[first..-1].each do |set_name|
    if Card.exists?("#{set_name}+#{rule_user_setting_name}")
      rule_cnt += 1
      res << if rule_cnt == 1
               [set_name, :current]
             else
               fallback_set ||= set_name
               [set_name, :overwritten]
             end
    else
      res << (rule_cnt < 1 ? [set_name, :enabled] : [set_name, :disabled])
    end
  end

  # fallback_set = if first > 0
  #                 res[0..(first-1)].find do |set_name|
  #                   Card.exists?("#{set_name}+#{rule_user_setting_name}")
  #                 end
  #               end
  # last = res.index{|s| s.to_name.key == cardname.trunk_name.key} || -1
  # # note, the -1 can happen with virtual cards because the self set doesn't
  # show up in the set_names.  FIXME!!
  # [res[first..last], fallback_set]
  #
  # The broadest set should always be the currently applied rule
  # (for anything more general, they must explicitly choose to 'DELETE' the
  # current one)
  # the narrowest rule should be the one attached to the set being viewed.
  # So, eg, if you're looking at the '*all plus' set, you shouldn't
  # have the option to create rules based on arbitrary narrower sets, though
  # narrower sets will always apply to whatever prototype we create

  return res, fallback_set
end

def set_prototype
  if is_user_rule?
    self[0..-3].prototype
  else
    trunk.prototype
  end
end
