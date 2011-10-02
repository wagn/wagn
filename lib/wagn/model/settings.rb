module Wagn::Model::Settings
  def setting setting_name, fallback=nil
    Rails.logger.debug "setting(#{setting_name}, #{fallback})"
    card = setting_card setting_name, fallback
    r=(card && card.content)
    Rails.logger.debug "setting(#{setting_name}, #{fallback}) #{r}"; r
  end

  def rule?
    return @rule unless @rule.nil?
    #Rails.logger.info "rule? #{name}, #{left&&"#{left.typename}:#{left.name}"}, #{right&&"#{right.typename}:#{right.name}"}" if junction?
    @rule = junction? ? (left&&left.typecode=='Set'&&right.typecode=='Setting') : false
  end

  def setting_card setting_name, fallback=nil
   r=
    real_set_names.first_value do |set_name|
      set_name=set_name.to_cardname
      Card[set_name.star_rule( setting_name )] ||
        fallback && Card[set_name.star_rule( fallback )]
    end
    Rails.logger.debug "setting_card(#{setting_name}, #{fallback}) #{r.inspect}"; r
  end
  def setting_card_with_cache setting_name, fallback=nil
    setting_name=setting_name.to_sym
    @setting_cards ||= {}  # FIXME: initialize this when creating card
    @setting_cards[setting_name] ||= 
      setting_card_without_cache setting_name, fallback
  end
  alias_method_chain :setting_card, :cache

  def related_sets
    sets = []
    sets<< "#{name}+*type" if typecode=='Cardtype'
    if cardname.simple?
      sets<< "#{name}+*right"
      Card.search(:type=>'Set',:left=>{:right=>name},:right=>'*type plus right',:return=>'name').each do |set_name|
        sets<< set_name
      end
    end
    sets
  end

  module ClassMethods
    def default_setting setting_name, fallback=nil
      card = default_setting_card setting_name, fallback
      return card && card.content
    end

    def default_setting_card setting_name, fallback=nil
      Card["*all".to_cardname.star_rule(setting_name)] or
        fallback ? default_setting_card(fallback) : nil
    end

    def universal_setting_names_by_group
      @@universal_setting_names_by_group ||= begin
        User.as(:wagbot) do
          setting_names = Card.search(:type=>'Setting', :return=>'name', :limit=>'0')
          grouped = {:view=>[], :edit=>[], :add=>[]}
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
    base.class_eval { attr_accessor :rule }
  end

end
