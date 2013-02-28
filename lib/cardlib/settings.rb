module Cardlib::Settings
  RuleSQL = %{
    select rules.id as rule_id, settings.id as setting_id, sets.id as set_id, sets.left_id as anchor_id, sets.right_id as set_tag_id
    from cards rules join cards sets on rules.left_id = sets.id join cards settings on rules.right_id = settings.id
    where sets.type_id     = #{Card::SetID }    and sets.trash     is false
    and   settings.type_id = #{Card::SettingID} and settings.trash is false
    and                                             rules.trash    is false; }
  
  def is_rule?
    !simple?   and 
    !new_card? and 
    l = left   and
    l.type_id==Card::SetID and
    r = right  and
    r.type_id==Card::SettingID 
  end
  
  def rule setting_code, options={}
    options[:skip_modules] = true
    card = rule_card setting_code, options
    card && card.content
  end
  
  def rule_card setting_code, options={}
    fallback = options.delete( :fallback )
    rule_set_keys.each do |rule_set_key|
      rule_id = self.class.rule_cache["#{rule_set_key}+#{setting_code}"]
      rule_id ||= fallback && self.class.rule_cache["#{rule_set_key}+#{fallback}"]
      return Card.fetch( rule_id, options) if rule_id
    end
    nil
  end
  

  def related_sets
    # refers to sets that users may configure from the current card - NOT to sets to which the current card belongs
    sets = ["#{name}+*self"]
    sets << "#{name}+*type" if type_id==Card::CardtypeID
    if cardname.simple?
      sets<< "#{name}+*right"
      Card.search(:type=>'Set',:left=>{:right=>name},:right=>'*type plus right',:return=>'name').each do |set_name|
        sets<< set_name
      end
    end
    sets
  end

  module ClassMethods
    def rule_cache
      @@rule_cache ||= Card.cache.read('RULES') || begin        
        hash = {}
        Account.as_bot do
          ActiveRecord::Base.connection.select_all( Cardlib::Settings::RuleSQL ).each do |row|
            setting_code = Wagn::Codename[ row['setting_id'].to_i ] or next
            anchor_id = row['anchor_id']
            set_class_id = anchor_id.nil? ? row['set_id'] : row['set_tag_id']
        
            set_class_code = Wagn::Codename[ set_class_id.to_i ] or next
            hash_key = [ anchor_id, set_class_code, setting_code ].compact.map( &:to_s ) * '+'
            hash[ hash_key ] = row['rule_id'].to_i
          end
        end
        Card.cache.write 'RULES', hash
      end
    end
    
    def clear_rule_cache local_only=false
      Card.cache.write 'RULES', nil unless local_only
      @@rule_cache = nil
    end
    
    def set_rule_cache hash
      #FIXME: should fail except in test envs.
      @@rule_cache = hash
    end
    
    def default_rule setting_code, fallback=nil
      card = default_rule_card setting_code, fallback
      return card && card.content
    end

    def default_rule_card setting_code, fallback=nil
      rule_id = rule_cache["all+#{setting_code}"]
      rule_id ||= fallback && rule_cache["all+#{fallback}"]
      Card[rule_id] if rule_id
    end

  end

  def self.included(base)
    super
    base.extend(ClassMethods)
  end

end
