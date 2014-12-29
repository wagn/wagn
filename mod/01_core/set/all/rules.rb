RuleSQL = %{
  select rules.id as rule_id, settings.id as setting_id, sets.id as set_id, sets.left_id as anchor_id, sets.right_id as set_tag_id
  from cards rules 
  join cards sets     on rules.left_id  = sets.id 
  join cards settings on rules.right_id = settings.id
  where sets.type_id     = #{Card::SetID }    and sets.trash     is false
  and   settings.type_id = #{Card::SettingID} and settings.trash is false
  and                                             rules.trash    is false;
}

ReadRuleSQL = %{
  select refs.referee_id as party_id, read_rules.id as read_rule_id
  from cards read_rules 
  join card_references refs on refs.referer_id    = read_rules.id 
  join cards sets           on read_rules.left_id = sets.id
  where read_rules.right_id = #{Card::ReadID} and read_rules.trash is false and sets.type_id = #{Card::SetID};
}

UserRuleSQL = %{
  select 
    user_rules.id as rule_id, 
    settings.id   as setting_id, 
    sets.id       as set_id, 
    sets.left_id  as anchor_id, 
    sets.right_id as set_tag_id,
    users.id      as user_id
  from cards user_rules 
  join cards rules    on user_rules.left_id   = rules.id 
  join cards sets     on rules.left_id        = sets.id 
  join cards settings on rules.right_id       = settings.id
  join cards users    on user_rules.right_id = users.id
  where   sets.type_id     =  #{Card::SetID }   and sets.trash     is false 
    and   settings.type_id = #{Card::SettingID} and settings.trash is false
    and   users.type_id    = #{Card::UserID}    and users.trash    is false
    and                                             rules.trash    is false;
}  

def user_rule_sql user_id=nil
  if user_id
    %{
      select 
        user_rules.id as rule_id, 
        settings.id   as setting_id, 
        sets.id       as set_id, 
        sets.left_id  as anchor_id, 
        sets.right_id as set_tag_id,
      from cards user_rules 
      join cards rules    on user_rules.left_id   = rules.id 
      join cards sets     on rules.left_id        = sets.id 
      join cards settings on rules.right_id       = settings.id
      where user_rules.right_id = #{user_id}
        and   sets.type_id      = #{Card::SetID }    and sets.trash     is false
        and   settings.type_id  = #{Card::SettingID} and settings.trash is false
        and                                              rules.trash    is false;
    }
  else
    UserRuleSQL
  end 
end


def is_rule?
  !simple?                             and
  ( (l = left( :skip_modules=>true ))  and
    l.type_id == Card::SetID           and
    (r = right( :skip_modules=>true ))  and
    r.type_id == Card::SettingID           ) or is_user_rule?
end

def is_user_rule?
  l = left(  :skip_modules=>true )  and
  l.is_rule?                        and
  r = right( :skip_modules=>true )  and
  r.type_id == Card::UserID          
end

def rule setting_code, options={}
  options[:skip_modules] = true
  card = rule_card setting_code, options
  card && card.db_content
end

def rule_card setting_code, options={}
  Card.fetch rule_card_id( setting_code, options ), options
end

def rule_card_id setting_code, options={}
  fallback = options.delete( :fallback )
  if options[:all_users]
    setting_code = "#{setting_code}+user_ids"
  elsif Card::Setting.user_specific? setting_code and Auth.signed_in?
    fallback = setting_code
    setting_code = "#{setting_code}+#{Auth.current_id}"
  end
  
  rule_set_keys.each do |rule_set_key|
    rule_id = self.class.rule_cache["#{rule_set_key}+#{setting_code}"]
    rule_id ||= fallback && self.class.rule_cache["#{rule_set_key}+#{fallback}"]
    return rule_id if rule_id
  end
  nil
end

def related_sets
  # refers to sets that users may configure from the current card - NOT to sets to which the current card belongs

  sets = []
  sets << ["#{name}+*type",  Card::TypeSet.label( name) ] if known? && type_id==Card::CardtypeID
  sets << ["#{name}+*self",  Card::SelfSet.label( name) ] 
  sets << ["#{name}+*right", Card::RightSet.label(name) ] if known? && cardname.simple?
    
#      Card.search(:type=>'Set',:left=>{:right=>name},:right=>'*type plus right',:return=>'name').each do |set_name|
#        sets<< set_name
#      end
  sets
end

module ClassMethods
  
  def setting name
    Auth.as_bot do
      card=Card[name] and !card.db_content.strip.empty? and card.db_content
    end
  end
  
  def path_setting name #shouldn't this be in location helper?
    name ||= '/'
    return name if name =~ /^(http|mailto)/
    "#{Wagn.config.relative_url_root}#{name}"
  end

  def toggle val
    val.to_s.strip == '1'
  end
  
  def all_user_ids set_card, setting_code
    key = if (l=set_card.left) and (r=set_card.right)
        set_class_code = Card::Codename[ r.id ]
        "#{l.id}+#{set_class_code}+#{setting_code}+all_users"
      else
        set_class_code = Card::Codename[ set_card.id ]
        "#{set_class_code}+#{setting_code}+all_users"
      end
    rule_cache[key] || []
  end
  
  def cached_keys_for_user user_id
    rule_cache["#{user_id}+rule_keys"] || []
  end

  def cache_key row
    setting_code = Card::Codename[ row['setting_id'].to_i ] or return false
    
    anchor_id = row['anchor_id']
    set_class_id = anchor_id.nil? ? row['set_id'] : row['set_tag_id']
    set_class_code = Card::Codename[ set_class_id.to_i ] or return false
    
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
    ActiveRecord::Base.connection.select_all(UserRuleSQL).each do |row|
      if key = cache_key(row) and user_id = row['user_id']
        yield(key, row['rule_id'].to_i, user_id.to_i)
      end
    end
  end
  
  def user_rule_keys_with_id_for user_id
    ActiveRecord::Base.connection.select_all(user_rule_sql(user_id)).each do |row|
      if key = cache_key(row)
        yield(key, row['rule_id'].to_i)
      end
    end
  end
  
  def user_rule_key key, user_id
    "#{key}+#{user_id}"
  end
  
  def all_users_key key
    "#{key}+all_users"
  end
  
  def all_rule_keys_key user_id
  end

  def rule_cache
    Card.cache.read('RULES') || begin        
      hash = {}
      all_rule_keys_with_id do |key,rule_id|
        hash[key] = rule_id
      end
      all_user_rule_keys_with_id_and_user_id do |key, rule_id, user_id|
        hash[ user_rule_key(key,user_id) ] = rule_id
        hash[ all_users_key(key)         ] ||= []
        hash[ all_users_key(key)         ] << user_id
        hash[ all_rule_keys_key(user_id) ] ||= []
        hash[ all_rule_keys_key(user_id) ] << key
      end
      Card.cache.write 'RULES', hash
    end
  end
  
  def clear_rule_cache
    Card.cache.write 'RULES', nil
  end
  
  def clear_user_rule_cache
    clear_rule_cache
  end
  
  def refresh_rule_cache_for_user user_id
    hash = rule_cache
    cached_keys_for_user(user_id).each do |key|
      hash[ user_rule_key(key, user_id) ] = nil
      hash[ all_users_key(key) ].delete(user_id)
    end
    hash[ all_rule_keys_key(user_id) ] = nil
    
    user_rule_keys_with_id_for(user_id) do |key, rule_id|
      hash[ user_rule_key(key,user_id) ] = rule_id
      hash[ all_users_key(key)         ] ||= []
      hash[ all_users_key(key)         ] << user_id
      hash[ all_rule_keys_key(user_id) ] ||= []
      hash[ all_rule_keys_key(user_id) ] << key
    end
  end
  
  def read_rule_cache
    Card.cache.read('READRULES') || begin
      hash = {}
      ActiveRecord::Base.connection.select_all( Card::Set::All::Rules::ReadRuleSQL ).each do |row|
        party_id, read_rule_id = row['party_id'].to_i, row['read_rule_id'].to_i
        hash[party_id] ||= []
        hash[party_id] << read_rule_id
      end
      Card.cache.write 'READRULES', hash
    end
  end
  
  def clear_read_rule_cache
    Card.cache.write 'READRULES', nil
  end
=begin  
  def default_rule setting_code, fallback=nil
    card = default_rule_card setting_code, fallback
    return card && card.content
  end

  def default_rule_card setting_code, fallback=nil
    rule_id = rule_cache["all+#{setting_code}"]
    rule_id ||= fallback && rule_cache["all+#{fallback}"]
    Card[rule_id] if rule_id
  end
=end  
end


