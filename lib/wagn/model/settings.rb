module Wagn::Model::Settings
  def rule setting_name, fallback=nil
    card = rule_card setting_name, fallback, :skip_modules=>true
    r=card && card.content
    #warn (Rails.logger.warn "rule[#{name}] #{setting_name}, #{card.inspect}, R:#{r}"); r
  end

=begin
  def rule?
    return @rule unless @rule.nil?
    warn (Rails.logger.info "rule? #{name}, #{left&&"#{left.typename}:#{left.name}"}, #{right&&"#{right.typename}:#{right.name}"}") if junction?
    @rule = junction? ? (left&&left.type_id==Card::SetID&&right.type_id==Card::SettingID) : false
  end
=end

  def rule_card setting_name, fallback=nil, extra_fetch_args={}
    #warn (Rails.logger.warn "rule_card[#{name}] #{setting_name}, #{fallback}, #{extra_fetch_args.inspect} RSN:#{real_set_names.inspect}") if setting_name == :read
    fetch_args = {:skip_virtual=>true}.merge extra_fetch_args
    real_set_names.each do |set_name|
      #warn (Rails.logger.debug "rule_card search #{set_name.inspect}") if setting_name == :read
      set_name=set_name.to_cardname
      card = Card.fetch(set_name.trait_name( setting_name ), fetch_args)
      card ||= fallback && Card.fetch(set_name.trait_name(fallback), fetch_args)
      #warn (Rails.logger.warn "rule #{name} [#{set_name}] #{card.inspect}") #if setting_name == :read
      return card if card
    end
    #warn (Rails.logger.warn "rc nothing #{setting_name}, #{name}") #if setting_name == :read
    nil
  end
  def rule_card_with_cache setting_name, fallback=nil, extra_fetch_args={}
    setting_name=setting_name.to_sym
    @rule_cards ||= {}  # FIXME: initialize this when creating card
    rcwc = (@rule_cards[setting_name] ||= 
      rule_card_without_cache setting_name, fallback, extra_fetch_args)
    #warn (Rails.logger.warn "rcwc #{rcwc.inspect}"); rcwc #if setting_name == :read; rcwc
  end
  alias_method_chain :rule_card, :cache

  def related_sets
    sets = ["#{name}+*self"]
    sets<< "#{name}+*type" if type_id==Card::CardtypeID
    if cardname.simple?
      sets<< "#{name}+*right"
      Card.search(:type=>'Set',:left=>{:right=>name},:right=>'*type plus right',:return=>'name').each do |set_name|
        sets<< set_name
      end
    end
    sets
  end

  module ClassMethods
    def default_rule setting_name, fallback=nil
      card = default_rule_card setting_name, fallback
      return card && card.content
    end

    def default_rule_card setting_name, fallback=nil
      Card["*all".to_cardname.trait_name(setting_name)] or
        fallback ? default_rule_card(fallback) : nil
    end

    def universal_setting_names_by_group
      @@universal_setting_names_by_group ||= begin
        Card.as(Card::WagbotID) do
          setting_ids = Card.search(:type=>Card::SettingID, :return=>'id', :limit=>'0')
          grouped = {:perms=>[], :look=>[], :com=>[], :other=>[]}
          warn Rails.logger.warn("setng ids #{setting_ids.inspect}")
          setting_ids.map do |setting_id|
            setting_code = Wagn::Codename[setting_id.to_i]
          warn Rails.logger.warn("setng id #{setting_code.inspect}")
            next unless group = Card.setting_group(setting_code)
            grouped[group] << setting_code
          end
          grouped.each_value do |name_list|
            name_list.sort!{ |x,y| Card.setting_seq(x) <=> Card.setting_seq(y)}
          end
        end
      end
    end

  
    SETTING_ATTRIBUTES = {
      :perms => [ :create, :read, :update, :delete, :comment ], 
      :look  => [ :default, :content, :layout, :table_of_content ], 
      :com   => [ :add_help, :edit_help, :send, :thanks ],
      :other => [ :autoname, :accountable, :captcha ]
    }

    @@setting_groups = @@setting_seqs = nil
    def load_setting_groups()
      @@setting_groups = {}
      @@setting_seqs = {}
      SETTING_ATTRIBUTES.each do |group, list|
        i=0
        list.each do |setting|
          i += 1
          @@setting_groups[setting]=group
          @@setting_seqs[setting]=i
        end
      end
    end

    def setting_group(codename)
      load_setting_groups if @@setting_groups.nil?
      r=@@setting_groups[codename]
      warn Rails.logger.warn("setting group #{codename}, #{r}"); r
    end
    def setting_seq(codename)
      load_setting_groups if @@setting_seqs.nil?
      r=@@setting_seqs[codename]
      warn Rails.logger.warn("setting seq #{codename}, #{r}"); r
    end

  end

  def self.included(base)
    super
    base.extend(ClassMethods)
  end

end
