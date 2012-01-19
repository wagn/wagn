module Wagn::Set::Type::Pointer

  def collection?() true  end

  def item_cards( args={} )
    if args[:complete]
      warn "item_card[#{args.inspect}], :complete"
      Wql.new({:referred_to_by=>name}.merge(args)).run
    else
      warn "item_card[#{inspect}], :complete"
      item_names(args).map do |name|
        c=Card.fetch_or_new(name)
        warn "item_card #{name}, #{c}"; c
      end.compact
    end
  end

  def item_ids( args={} ) item_cards.map(&:id) end

  def item_names( args={} )
    context = args[:context] || self.cardname
    links = content.split(/\n+/).map{ |line|
      line.gsub(/\[\[|\]\]/,'')}.map{|link|
      r=context==:raw ? link : link.to_cardname.to_absolute(context)
    }
  end

  def item_type
    opt = options_card
    return nil if (!opt || opt==self)  #fixme, need better recursion prevention
    opt.item_type
  end

  def << card
    add_item case card
               when Card; card.name
               when Integer; c = Card[card] and c.name
               else card end
    self
  end

  def add_item name
    unless item_names.include? name
      self.content="[[#{(item_names << name).reject(&:blank?)*"]]\n[["}]]"
      save!
    end
  end

  def drop_item name
    if item_names.include? name
      nitems = item_names.reject{|n|n==name||n.blank?}
      self.content= nitems.empty? ? '' : "[[#{nitems*"]]\n[["}]]"
      save!
    end
  end

  def options_card
    card = self.rule_card('options')
    (card && card.collection?) ? card : nil
  end

  def options
    (oc=self.options_card) ? oc.item_cards(:default_limit=>50) : Card.search(:sort=>'alpha',:limit=>50)
  end

  def option_text(option)
    name = self.rule('option label') || 'description'
    textcard = Card["#{option}+#{name}"]
    textcard ? textcard.content : nil
  end
end
