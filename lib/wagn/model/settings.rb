module Wagn::Model::Settings
  def rule setting_name, fallback=nil
    card = rule_card setting_name, fallback, :skip_modules=>true
    card && card.content
  end

#  def rule?
#    return @rule unless @rule.nil?
#    #Rails.logger.info "rule? #{name}, #{left&&"#{left.typename}:#{left.name}"}, #{right&&"#{right.typename}:#{right.name}"}" if junction?
#    @rule = junction? ? (left&&left.typecode=='Set'&&right.typecode=='Setting') : false
#  end

  def rule_card setting_name, fallback=nil, extra_fetch_args={}
    #warn "rule_card #{setting_name}, #{fallback}, #{extra_fetch_args.inspect}"
    fetch_args = {:skip_virtual=>true}.merge extra_fetch_args
    real_set_names.each do |set_name|
      #Rails.logger.debug "rule_card search #{set_name.inspect}"
      set_name=set_name.to_cardname
      card = Card.fetch(set_name.star_rule( setting_name ), fetch_args)
      card ||= fallback && Card.fetch(set_name.star_rule(fallback), fetch_args)
      #warn "rule[#{set_name}] #{card.inspect}" if card
      return card if card
    end
    #warn "rc nothing #{setting_name}, #{name}"
    nil
  end
  def rule_card_with_cache setting_name, fallback=nil, extra_fetch_args={}
    setting_name=setting_name.to_sym
    @rule_cards ||= {}  # FIXME: initialize this when creating card
    @rule_cards[setting_name] ||= 
      rule_card_without_cache setting_name, fallback, extra_fetch_args
  end
  alias_method_chain :rule_card, :cache

  def related_sets
    sets = ["#{name}+*self"]
    sets<< "#{name}+*type" if type_id==Wagn::Codename.cardname_type_id
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
      Card["*all".to_cardname.star_rule(setting_name)] or
        fallback ? default_rule_card(fallback) : nil
    end

    def universal_setting_names_by_group
      @@universal_setting_names_by_group ||= begin
        Card.as(Card::WagbotID) do
          setting_names = Card.search(:type=>'Setting', :return=>'name', :limit=>'0')
          grouped = {:perms=>[], :look=>[], :com=>[], :other=>[]}
          setting_names.map(&:to_cardname).each do |cardname|
            next unless group = Card.setting_attrib(cardname, :setting_group)
            grouped[group] << cardname
          end
          grouped.each_value do |name_list|
            name_list.sort!{ |x,y| Card.setting_attrib(x, :setting_seq) <=> Card.setting_attrib(y, :setting_seq)}
          end
        end
      end
    end

    def setting_attrib(cardname, attrib)
      const = eval("Wagn::Set::Self::#{cardname.module_name}")
      const.send attrib
    rescue
      Rails.logger.info "nothing found for #{cardname.module_name}, #{attrib}"
      nil
    end
  end

  def self.included(base)
    super
    base.extend(ClassMethods)
    #base.class_eval { attr_accessor :rule }
  end

end
