module Cardlib::Settings
  def rule setting_name, options={}
    #warn "rule #{setting_name.inspect}, #{options.inspect}"
    options[:skip_modules] = true
    card = rule_card setting_name, options
    card && card.content
  end

  def rule_card setting_name, options={}
    fallback = options.delete( :fallback )
    fetch_args = {:skip_virtual=>true}.merge options
    #warn "rule_card[#{name}] #{setting_name}, #{options.inspect} RSN:#{real_set_names.inspect}" if name =~ /Jim\+birthday/
    real_set_names.each do |set_name|
      #warn "rule_card search #{set_name.inspect}" if name =~ /Jim\+birthday/
      set_name=set_name.to_name
      card = Card.fetch(set_name.trait_name( setting_name ), fetch_args)
      card ||= fallback && Card.fetch(set_name.trait_name(fallback), fetch_args)
      #warn "rule #{name} [#{set_name}] rc:#{card.inspect}" if name =~ /Jim\birthday/
#      return card if card
      if card
        @@correct_rules ||= 0
        nrcid = new_rule_card setting_name, :fallback=>fallback
        if nrcid == card.id
          Rails.logger.info "correct rule id: #{@@correct_rules += 1}"
        else
          new_card = Card[nrcid]
          warn "incorrect rule: old = #{card.name}, new = #{new_card && new_card.name}"
        end
        return card
      end
    end
    #warn (Rails.logger.warn "rc nothing #{setting_name}, #{name}") if name =~ /Jim\birthday/
    nil
  end
  
  def new_rule_card setting_code, options
    fallback = options.delete( :fallback )
    rule_set_keys.each do |rule_set_key|
      rule_id = self.class.rule_cache["#{rule_set_key}+#{setting_code}"] or
        ( fallback && self.class.rule_cache["#{rule_set_key}+#{fallback}"] )
      return rule_id if rule_id
#      return Card[rule_id] if rule_id
    end
    nil
  end
  
  def rule_card_with_cache setting_name, options={}
    setting_name = (sc=Card[setting_name] and (sc.codename || sc.name).to_sym) unless Symbol===setting_name
    @rule_cards ||= {}  # FIXME: initialize this when creating card
    rcwc = (@rule_cards[setting_name] ||=
      rule_card_without_cache setting_name, options)
    #warn (Rails.logger.warn "rcwc #{rcwc.inspect}"); rcwc #if setting_name == :read; rcwc
  end
  alias_method_chain :rule_card, :cache

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
      @@rule_cache ||= begin
        hash = {}
        Account.as_bot do
          rule_wql = { :left=>{ :type_id=>Card::SetID }, :right=>{ :type_id=>Card::SettingID } }
          Card.search( rule_wql ).each do |rule_card|
            setting_code = Wagn::Codename[ rule_card.right_id ] or next
            if rule_card.cardname.trunk_name.simple?
              anchor_id = nil
              set_class_id = rule_card.left_id
            else
              set_card = rule_card.left 
              anchor_id = set_card.left_id
              set_class_id = set_card.right_id
            end
        
            set_class_code = Wagn::Codename[set_class_id] or next
            hash_key = [ anchor_id, set_class_code, setting_code ].compact.map( &:to_s ) * '+'
            hash[ hash_key ] = rule_card.id
          end
        end
        hash
      end
    end
    
    def clear_rule_cache
      @@rule_cache = nil
    end
    
    def default_rule setting_name, fallback=nil
      card = default_rule_card setting_name, fallback
      return card && card.content
    end

    def default_rule_card setting_name, fallback=nil
      Card["*all".to_name.trait_name(setting_name)] or
        fallback ? default_rule_card(fallback) : nil
    end
  end

  def self.included(base)
    super
    base.extend(ClassMethods)
  end

end
