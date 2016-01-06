RuleSQL = %{
  select rules.id as rule_id, settings.id as setting_id, sets.id as set_id,
    sets.left_id as anchor_id, sets.right_id as set_tag_id
  from cards rules
  join cards sets     on rules.left_id  = sets.id
  join cards settings on rules.right_id = settings.id
  where sets.type_id     = #{Card::SetID }    and sets.trash     is false
  and   settings.type_id = #{Card::SettingID} and settings.trash is false
  and                                             rules.trash    is false
  and   (settings.codename != 'follow' or rules.db_content != '');
}

ReadRuleSQL = %{
  select refs.referee_id as party_id, read_rules.id as read_rule_id
  from cards read_rules
  join card_references refs on refs.referer_id    = read_rules.id
  join cards sets           on read_rules.left_id = sets.id
  where read_rules.right_id = #{Card::ReadID} and read_rules.trash is false and sets.type_id = #{Card::SetID};
}

def is_rule?
  is_standard_rule? || is_user_rule?
end

def is_standard_rule?
  (r = right( skip_modules: true ))  &&
    r.type_id == Card::SettingID     &&
    (l = left( skip_modules: true )) &&
    l.type_id == Card::SetID
end

def is_user_rule?
  cardname.parts.length > 2                                  &&
  (r = right( skip_modules: true ))                         &&
   r.type_id == Card::SettingID                              &&
  (set = self[0..-3, skip_modules: true])                   &&
   set.type_id == Card::SetID                                &&
  (user = self[-2, skip_modules: true] )                    &&
  (user.type_id == Card::UserID  || user.codename == 'all' )
end


def rule setting_code, options={}
  options[:skip_modules] = true
  card = rule_card setting_code, options
  card && card.db_content
end

def rule_card setting_code, options={}
  Card.fetch rule_card_id(setting_code, options), options
end

def rule_card_id setting_code, options={}
  fallback = options.delete( :fallback )

  if Card::Setting.user_specific? setting_code
    user_id = options[:user_id] || (options[:user] and options[:user].id) || Auth.current_id
    if user_id
      fallback = "#{setting_code}+#{AllID}"
      setting_code = "#{setting_code}+#{user_id}"
    end
  end

  rule_set_keys.each do |rule_set_key|
    rule_id = self.class.rule_cache["#{rule_set_key}+#{setting_code}"]
    rule_id ||= fallback && self.class.rule_cache["#{rule_set_key}+#{fallback}"]
    return rule_id if rule_id
  end
  nil
end

def related_sets with_self = false
  # refers to sets that users may configure from the current card -
  # NOT to sets to which the current card belongs

  # FIXME: change to use codenames!!

  sets = []
  if known? && type_id == Card::CardtypeID # FIXME: belongs in type/cardtype
    sets << ["#{name}+*type", Card::TypeSet.label(name)]
  end
  if with_self
    sets << ["#{name}+*self", Card::SelfSet.label(name)]
  end
  if known? && cardname.simple?
    sets << ["#{name}+*right", Card::RightSet.label(name)]
  end
  sets
end

module ClassMethods

  # User-specific rule use the pattern
  # user+set+setting
  def user_rule_sql user_id=nil
    user_restriction = if user_id
        "users.id = #{user_id}"
      else
        "users.type_id = #{Card::UserID}"
      end

    %{
      select
        user_rules.id as rule_id,
        settings.id   as setting_id,
        sets.id       as set_id,
        sets.left_id  as anchor_id,
        sets.right_id as set_tag_id,
        users.id      as user_id
      from cards user_rules
      join cards user_sets on user_rules.left_id  = user_sets.id
      join cards settings  on user_rules.right_id = settings.id
      join cards users     on user_sets.right_id  = users.id
      join cards sets      on user_sets.left_id = sets.id
      where sets.type_id     = #{Card::SetID }
        and settings.type_id = #{Card::SettingID}
        and (#{user_restriction} or users.codename = 'all')
        and sets.trash       is false
        and settings.trash   is false
        and users.trash      is false
        and user_sets.trash  is false
        and user_rules.trash is false;
    }
  end

  def global_setting name
    Auth.as_bot do
      (card = Card[name]) && !card.db_content.strip.empty? && card.db_content
    end
  end

  def path_setting name #shouldn't this be in location helper?
    name ||= '/'
    return name if name =~ /^(http|mailto)/
    "#{Card.config.relative_url_root}#{name}"
  end

  def toggle val
    val.to_s.strip == '1'
  end

  def cache_key row
    setting_code = Codename[ row['setting_id'].to_i ] or return false

    anchor_id = row['anchor_id']
    set_class_id = anchor_id.nil? ? row['set_id'] : row['set_tag_id']
    set_class_code = Codename[ set_class_id.to_i ] or return false

    key_base = [ anchor_id, set_class_code, setting_code].compact.map( &:to_s ) * '+'
  end

  def all_rule_keys_with_id
    ActiveRecord::Base.connection.select_all(RuleSQL).each do |row|
      if key = cache_key(row)
        yield(key, row['rule_id'].to_i)
      end
    end
  end

  def all_user_rule_keys_with_id_and_user_id
    ActiveRecord::Base.connection.select_all(user_rule_sql).each do |row|
      if key = cache_key(row) and user_id = row['user_id']
        yield(key, row['rule_id'].to_i, user_id.to_i)
      end
    end
  end

  def all_rule_keys_with_id_for user_id
    ActiveRecord::Base.connection.select_all(user_rule_sql(user_id)).each do |row|
      if key = cache_key(row)
        yield(key, row['rule_id'].to_i)
      end
    end
  end

  def cached_rule_keys_for user_id
    rule_keys_cache[user_id] || []
  end

  def all_user_ids_with_rule_for set_card, setting_code
    key =
      if (l = set_card.left) && (r = set_card.right)
        set_class_code = Codename[r.id]
        "#{l.id}+#{set_class_code}+#{setting_code}"
      else
        set_class_code = Codename[set_card.id]
        "#{set_class_code}+#{setting_code}"
      end
    user_ids = user_ids_cache[key] || []
    if user_ids.include? AllID  # rule for all -> return all user ids
      Card.where(type_id: UserID).pluck(:id)
    else
      user_ids
    end
  end

  def user_rule_cards user_name, setting_code
    Card.search(
      { right: { codename: setting_code },
        left: { left: { type_id: SetID }, right: user_name }
        }, "rule cards for user: #{user_name}"
    )
  end

  def rule_cache
    Card.cache.read('RULES') || begin
      rule_hash = {}
      all_rule_keys_with_id do |key,rule_id|
        rule_hash[key] = rule_id
      end

      user_ids_hash = {}
      rule_keys_hash = {}
      all_user_rule_keys_with_id_and_user_id do |key, rule_id, user_id|
        rule_hash[ user_rule_key(key,user_id) ] = rule_id
        user_ids_hash[key] ||= []
        user_ids_hash[key] << user_id
        rule_keys_hash[user_id] ||= []
        rule_keys_hash[user_id] << key
      end
      write_user_ids_cache user_ids_hash
      write_rule_keys_cache rule_keys_hash
      write_rule_cache rule_hash
    end
  end

  def user_rule_key key, user_id
    "#{key}+#{user_id}"
  end

  # all users that have a user-specific rule for a given rule key
  def user_ids_cache
    Card.cache.read('USER_IDS') || begin
      rule_cache
      Card.cache.read('USER_IDS')
    end
  end

  # all keys of user-specific rules for a given user
  def rule_keys_cache
    Card.cache.read('RULE_KEYS') || begin
      rule_cache
      Card.cache.read('RULE_KEYS')
    end
  end

  def clear_rule_cache
    write_rule_cache nil
    write_user_ids_cache nil
    write_rule_keys_cache nil
  end

  def clear_user_rule_cache
    clear_rule_cache
  end

  def refresh_rule_cache_for_user user_id
    rule_hash = rule_cache
    user_ids_hash = user_ids_cache
    rule_keys_hash = rule_keys_cache

    cached_rule_keys_for(user_id).each do |key|
      rule_hash[ user_rule_key(key, user_id) ] = nil
      user_ids_hash[ key ].delete(user_id)
    end
    rule_keys_hash[ user_id ] = nil

    all_rule_keys_with_id_for(user_id) do |key, rule_id|
      rule_hash[ user_rule_key(key,user_id) ] = rule_id

      user_ids_hash[ key ]      ||= []
      user_ids_hash[ key ]      << user_id
      rule_keys_hash[ user_id ] ||= []
      rule_keys_hash[ user_id ] << key
    end
    write_user_ids_cache user_ids_hash
    write_rule_keys_cache rule_keys_hash
    write_rule_cache rule_hash
  end

  def write_rule_cache hash
    Card.cache.write 'RULES', hash
  end

  def write_user_ids_cache hash
    Card.cache.write 'USER_IDS', hash
  end

  def write_rule_keys_cache hash
    Card.cache.write 'RULE_KEYS', hash
  end

  def read_rule_cache
    Card.cache.read('READRULES') || begin
      hash = {}
      ActiveRecord::Base.connection.select_all(
        Card::Set::All::Rules::ReadRuleSQL
      ).each do |row|
        party_id = row['party_id'].to_i
        hash[party_id] ||= []
        hash[party_id] << row['read_rule_id'].to_i
      end
      Card.cache.write 'READRULES', hash
    end
  end

  def clear_read_rule_cache
    Card.cache.write 'READRULES', nil
  end
end
