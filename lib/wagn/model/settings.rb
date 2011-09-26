module Wagn::Model::Settings
  def setting setting_name, fallback=nil
    card = setting_card setting_name, fallback
    Rails.logger.debug "setting[#{inspect}, #{setting_name}] #{card&&card.inspect}"
    card && card.content
  end

  def setting_card setting_name, fallback=nil
    #Rails.logger.info "setting_card[#{name}](#{setting_name.inspect}, #{fallback.inspect})"
    fetch_args = {:skip_virtual=>true, :skip_after_fetch=>true}

    real_set_names.each do |name|
      #next unless Card.fetch(name, fetch_args)  'real_set_names doesn't return them'
      # optimization for cases where there are lots of settings lookups for many sets though few exist.
      # May cause problems if we wind up with Set in trash, since trunks aren't always getting pulled out when we
      # create plus cards (like setting values)
      #Rails.logger.info "setting_card, search #{setting_name.inspect}, #{fallback.inspect} #{name.inspect}" # Tr:#{Kernel.caller[0..10]*"\n"}"
      if setting_cd = Card.fetch(cn="#{name}+#{setting_name.to_cardname.to_star}", fetch_args) ||
         fallback && Card.fetch(cn="#{name}+#{fallback.to_cardname.to_star}", fetch_args)
        #Rails.logger.debug "setting_card, found #{cn.inspect}, #{name.inspect}\nFound > #{setting_cd.inspect}"
#        setting_cd.after_fetch
        return setting_cd
      end
    end
    #Rails.logger.info "setting_card, NF #{name.inspect}"
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
      setting_card = Card.fetch( "*all+#{setting_name.to_cardname.to_star}" , :skip_virtual => true) or
        (fallback ? default_setting_card(fallback) : nil)
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
