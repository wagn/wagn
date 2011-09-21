module Wagn::Model::Settings
  def setting setting_name, fallback=nil
    card = setting_card setting_name, fallback
    card && card.content
  end

  def rule?
    return @rule unless @rule.nil?
    @rule = junction? ?
        card.left.typecode=='Set' && card.right.typecode=='Setting' : false 
  end

  def setting_card setting_name, fallback=nil
    #warn "setting_card[#{name}](#{setting_name.inspect}, #{fallback.inspect})" if name.to_s == 'Foo Bar'
    
    set_names = real_set_names or raise( "no real set names found for #{name}" )
    
    
#    warn "set_names = #{set_names.inspect}" if name.to_s == 'A+*self'
    r=
    
    
    set_names.first_value do |set_name|
#      warn "#setting_card, setname = #{set_name}; setting name =  #{setting_name.inspect}, #{fallback.inspect} #{name.inspect}" if name.to_s == 'A+*self'

      if (rule_card=Card[[set_name, setting_name.to_cardname.to_star].to_cardname]) &&
         rule_card.real? || (fallback &&
         (rule_card=Card[[set_name, fallback.to_cardname.to_star].to_cardname]) &&
         rule_card.real?)
        Rails.logger.debug "setting_card, found[#{rule_card.name}]"
        rule_card
      end
    end
#    warn "setting_card result [#{name.inspect}, #{setting_name}] RRR>#{r}" if name.to_s == 'A+*self'; r
  end

  #def settings() @settings ||= {} end

=begin
  def setting_card_with_cache setting_name, fallback=nil
    #warn "setting_card wc[#{name.inspect}](#{setting_name.inspect}, #{fallback.inspect}) #{self.settings[setting_name].nil?} <<< #{self.settings.map{|k,v|"#{k} => #{v and v.cardname.inspect}"}*"\n"}>>>"
    #Rails.logger.info "setting cardinfo[#{name}] #{self.settings.keys.map{|k|"#{k} => #{c=self.settings[k] and c.name}"}.inspect}"
    rule_card = self.settings[setting_name]
    #warn "setting cache fetch[#{set_name&&set_name.cardname.inspect}]";
    if rule_card.nil?
      rule_card = setting_card_without_cache(setting_name, fallback) 
      self.settings[setting_name]= rule_card if rule_card
#      Rails.logger.debug "setting cache store[#{rule_card.name}]"
    else 
#      Rails.logger.debug "setting cache ret[#{set_name && set_name.cardname.inspect}]"
    end
    #warn "returning rule name = #{rule_card.name}"
    rule_card
    #rr=(setng = self.settings[setting_name]).nil? ?
    #  (cres=( self.settings[setting_name]= begin
    #   r=setting_card_without_cache(setting_name, fallback)
    #   raise "???" if r == '*'
    #   Rails.logger.debug "setting cache fetch[#{(r!='*')? r.cardname.inspect : '*'}]"; r
    #                                     end || false )) : setng
    # Rails.logger.debug "setting cache store[#{(cres!='*')? cres.cardname.inspect : '*'}] #{(cres != rr && rr.cardname.inspect)}"; rr
  end
  alias_method_chain :setting_card, :cache
=end

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
      Rails.logger.info "default_setting card #{setting_name}, #{fallback}"
      setting_card = Card[ "*all+#{setting_name.to_cardname.to_star}"] or
        (fallback ? default_setting_card(fallback) : nil)
      Rails.logger.info "default_setting card #{setting_name}, #{setting_card.cardname.inspect}"; setting_card
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
          grouped
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
