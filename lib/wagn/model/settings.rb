module Wagn::Model::Settings
  def setting setting_name, fallback=nil
    card = setting_card setting_name, fallback, :skip_module_loading=>true
    card && card.content
  end

  def setting_card setting_name, fallback=nil, extra_fetch_args={}
    fetch_args = {:skip_virtual=>true}.merge extra_fetch_args
    real_set_names.each do |set_name|
      rule_card = Card.fetch "#{set_name}+#{setting_name.to_cardname.to_star}", fetch_args
      rule_card ||= fallback && Card.fetch("#{set_name}+#{fallback.to_cardname.to_star}", fetch_args)
      return rule_card if rule_card
    end
    return nil
  end

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
      Card["*all+#{setting_name.to_cardname.to_star}"] or (fallback ? default_setting_card(fallback) : nil)
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
      Rails.logger.info "nothing found for #{name.to_cardname.module_name}, #{attrib}"
      nil
    end
  end

  def self.included(base)
    super
    base.extend(ClassMethods)
  end

end
