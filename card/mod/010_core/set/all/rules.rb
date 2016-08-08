# frozen_string_literal: true

RULE_SQL = %(
  SELECT
    rules.id      AS rule_id,
    settings.id   AS setting_id,
    sets.id       AS set_id,
    sets.left_id  AS anchor_id,
    sets.right_id AS set_tag_id
  FROM cards rules
  JOIN cards sets     ON rules.left_id  = sets.id
  JOIN cards settings ON rules.right_id = settings.id
  WHERE     sets.type_id = #{Card::SetID}
    AND settings.type_id = #{Card::SettingID}
    AND (settings.codename != 'follow' OR rules.db_content != '')
    AND    rules.trash is false
    AND     sets.trash is false
    AND settings.trash is false;
).freeze

# FIXME: "follow" hardcoded above

READ_RULE_SQL = %(
  SELECT
    refs.referee_id AS party_id,
    read_rules.id   AS read_rule_id
  FROM cards read_rules
  JOIN card_references refs ON refs.referer_id    = read_rules.id
  JOIN cards sets           ON read_rules.left_id = sets.id
  WHERE read_rules.right_id = #{Card::ReadID}
    AND       sets.type_id  = #{Card::SetID}
    AND read_rules.trash is false
    AND       sets.trash is false;
).freeze

PREFERENCE_SQL = %(
  SELECT
    preferences.id AS rule_id,
    settings.id    AS setting_id,
    sets.id        AS set_id,
    sets.left_id   AS anchor_id,
    sets.right_id  AS set_tag_id,
    users.id       AS user_id
  FROM cards preferences
  JOIN cards user_sets ON preferences.left_id  = user_sets.id
  JOIN cards settings  ON preferences.right_id = settings.id
  JOIN cards users     ON user_sets.right_id   = users.id
  JOIN cards sets      ON user_sets.left_id    = sets.id
  WHERE sets.type_id     = #{Card::SetID}
    AND settings.type_id = #{Card::SettingID}
    AND (%s or users.codename = 'all')
    AND sets.trash        is false
    AND settings.trash    is false
    AND users.trash       is false
    AND user_sets.trash   is false
    AND preferences.trash is false;
).freeze

def is_rule?
  is_standard_rule? || is_preference?
end

def is_standard_rule?
  (r = right(skip_modules: true)) &&
    r.type_id == Card::SettingID &&
    (l = left(skip_modules: true)) &&
    l.type_id == Card::SetID
end

def is_preference?
  cardname.parts.length > 2 &&
    (r = right(skip_modules: true)) &&
    r.type_id == Card::SettingID &&
    (set = self[0..-3, skip_modules: true]) &&
    set.type_id == Card::SetID &&
    (user = self[-2, skip_modules: true]) &&
    (user.type_id == Card::UserID || user.codename == "all")
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
  fallback = options.delete :fallback

  if Card::Setting.user_specific? setting_code
    fallback, setting_code = preference_card_id_lookups setting_code, options
  end

  rule_set_keys.each do |rule_set_key|
    rule_id = self.class.rule_cache["#{rule_set_key}+#{setting_code}"]
    rule_id ||= fallback && self.class.rule_cache["#{rule_set_key}+#{fallback}"]
    return rule_id if rule_id
  end
  nil
end

def preference_card_id_lookups setting_code, options={}
  user_id = options[:user_id] ||
            (options[:user] && options[:user].id) ||
            Auth.current_id
  return unless user_id
  ["#{setting_code}+#{AllID}", "#{setting_code}+#{user_id}"]
end

def related_sets with_self=false
  # refers to sets that users may configure from the current card -
  # NOT to sets to which the current card belongs

  # FIXME: change to use codenames!!

  sets = []
  if known? && type_id == Card::CardtypeID # FIXME: belongs in type/cardtype
    sets << ["#{name}+*type", Card::TypeSet.label(name)]
  end
  sets << ["#{name}+*self", Card::SelfSet.label(name)] if with_self
  if known? && cardname.simple?
    sets << ["#{name}+*right", Card::RightSet.label(name)]
  end
  sets
end

module ClassMethods
  # User-specific rule use the pattern
  # user+set+setting
  def preference_sql user_id=nil
    user_restriction =
      if user_id
        "users.id = #{user_id}"
      else
        "users.type_id = #{Card::UserID}"
      end
    PREFERENCE_SQL % user_restriction
  end

  def global_setting name
    Auth.as_bot do
      (card = Card[name]) && !card.db_content.strip.empty? && card.db_content
    end
  end

  def path_setting name # shouldn't this be in location helper?
    name ||= "/"
    return name if name =~ /^(http|mailto)/
    "#{Card.config.relative_url_root}#{name}"
  end

  def toggle val
    val.to_s.strip == "1"
  end

  def rule_cache_key row
    return false unless (setting_code = Codename[row["setting_id"].to_i])

    anchor_id = row["anchor_id"]
    set_class_id = anchor_id.nil? ? row["set_id"] : row["set_tag_id"]
    return false unless (set_class_code = Codename[set_class_id.to_i])

    [anchor_id, set_class_code, setting_code].compact.map(&:to_s) * "+"
  end

  def interpret_simple_rules
    ActiveRecord::Base.connection.select_all(RULE_SQL).each do |row|
      next unless (key = rule_cache_key row)
      @rule_hash[key] = row["rule_id"].to_i
    end
  end

  def interpret_preferences
    ActiveRecord::Base.connection.select_all(preference_sql).each do |row|
      next unless (key = rule_cache_key row) && (user_id = row["user_id"])
      add_preference_hash_values key, row["rule_id"].to_i, user_id.to_i
    end
  end

  def add_preference_hash_values key, rule_id, user_id
    @rule_hash[preference_key(key, user_id)] = rule_id
    @user_ids_hash[key] ||= []
    @user_ids_hash[key] << user_id
    @rule_keys_hash[user_id] ||= []
    @rule_keys_hash[user_id] << key
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

  def preference_names user_name, setting_code
    Card.search(
      { right: { codename: setting_code },
        left: {
          left: { type_id: SetID }, right: user_name
        },
        return: :name
      }, "preference cards for user: #{user_name}"
    )
  end

  def preference_cards user_name, setting_code
    preference_names(user_name, setting_code).map { |name| Card.fetch name }
  end

  def rule_cache
    Card.cache.read("RULES") || begin
      @rule_hash = {}
      @user_ids_hash = {}
      @rule_keys_hash = {}

      interpret_simple_rules
      interpret_preferences

      write_user_ids_cache @user_ids_hash
      write_rule_keys_cache @rule_keys_hash
      write_rule_cache @rule_hash
    end
  end

  def preference_key key, user_id
    "#{key}+#{user_id}"
  end

  # all users that have a user-specific rule for a given rule key
  def user_ids_cache
    Card.cache.read("USER_IDS") ||
      begin
      clear_rule_cache
      rule_cache
      @user_ids_hash
    end
  end

  # all keys of user-specific rules for a given user
  def rule_keys_cache
    Card.cache.read("RULE_KEYS") || begin
      clear_rule_cache
      rule_cache
      @rule_keys_hash
    end
  end

  def clear_rule_cache
    write_rule_cache nil
    write_user_ids_cache nil
    write_rule_keys_cache nil
  end

  def clear_preference_cache
    # FIXME: too entwined!
    clear_rule_cache
  end

  def write_rule_cache hash
    Card.cache.write "RULES", hash
  end

  def write_user_ids_cache hash
    Card.cache.write "USER_IDS", hash
  end

  def write_rule_keys_cache hash
    Card.cache.write "RULE_KEYS", hash
  end

  def read_rule_cache
    Card.cache.read("READRULES") || begin
      hash = {}
      Card.connection.select_all(
        Card::Set::All::Rules::READ_RULE_SQL
      ).each do |row|
        party_id = row["party_id"].to_i
        hash[party_id] ||= []
        hash[party_id] << row["read_rule_id"].to_i
      end
      Card.cache.write "READRULES", hash
    end
  end

  def clear_read_rule_cache
    Card.cache.write "READRULES", nil
  end
end
