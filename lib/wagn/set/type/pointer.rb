module Wagn::Set::Type::Pointer

  def collection?() true  end

  def item_cards( args={} )
    if args[:complete]
    Rails.logger.debug "itemcards C #{name}"
      Wql.new({:referred_to_by=>name}.merge(args)).run
    else
    Rails.logger.debug "itemcards #{name}"
      item_names(args).map {|name|
    Rails.logger.debug "itemcards #{name.inspect}"
        Card.fetch_or_new(name, :skip_defaults=>true) }.compact
    end
  end

  def item_names( args={} )
    context = args[:context] || self.cardname
    links = content.split(/\n+/).map{ |line|
      #Rails.logger.debug "item Line #{name.inspect}, #{line.inspect}"
      line.gsub(/\[\[|\]\]/,'')}.map{|link|
      r=context==:raw ? link : link.to_cardname.to_absolute(context)
      #Rails.logger.debug "itemR Link#{name.inspect}, #{link.inspect} > #{r.inspect}"; r
    }
      Rails.logger.debug "items Lines #{name.inspect}, #{links.inspect}"; links
  end

  def item_type
    opt = options_card
    return nil if (!opt || opt==self)  #fixme, need better recursion prevention
    opt.item_type
  end

  def add_item( cardname )
    Rails.logger.debug "add_item #{cardname.inspect}, #{item_names.inspect}"
    r=
    unless item_names.include? cardname
      self.content = (item_names + [cardname]).reject{|x|x.blank?}.map{|x| "[[#{x}]]" }.join("\n")
      save!
    end
    Rails.logger.debug "add_item #{cardname.inspect}, #{item_names.inspect} > #{r.inspect}"; r
  end 
                                
  def drop_item( cardname ) 
    Rails.logger.debug "drop_item #{cardname.inspect}, #{item_names.inspect}"
    if item_names.include? cardname
      self.content = (item_names - [cardname]).map{|x| "[[#{x}]]"}*"\n"
      #r1= (item_names - [cardname]); r2=r1.map{|x| "[[#{x}]]"}; r3=r2*"\n"
      #Rails.logger.debug "drop_item #{r1.inspect}, #{r2.inspect} :: #{r3.inspect}"; self.content = r3
      save!
      #Rails.logger.debug "drop_item #{r4.inspect}"
    end
    Rails.logger.debug "drop_item #{cardname.inspect}, #{item_names.inspect} > #{self.content.inspect}"
  end
  
  def options_card
    card = self.setting_card('options')
    card.after_fetch if card
    (card && card.collection?) ? card : nil
  end

  def options
    (oc=self.options_card) ? oc.item_cards(:default_limit=>50) : Card.search(:sort=>'alpha',:limit=>50)
  end

  def option_text(option)
    name = setting('option label') || 'description'
    textcard = Card.fetch(option+'+'+name, :skip_virtual => true)
    textcard ? textcard.content : nil
  end
end
