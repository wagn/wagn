module Wagn::Set::Type::Pointer

  def collection?() true  end

  def item_cards( args={} )
    if args[:complete]
      #warn "item_card[#{args.inspect}], :complete"
      Wql.new({:referred_to_by=>name}.merge(args)).run
    else
      #warn "item_card[#{inspect}], :complete"
      item_names(args).map do |name|
        c=Card.fetch_or_new(name)
        #warn "item_card #{name}, #{c}"; c
      end.compact
    end
  end

  def item_names( args={} )
    context = args[:context] || self.cardname
    cc=self.content
    self.content.split(/\n+/).map{ |line|
      line.gsub(/\[\[|\]\]/,'')
    }.map{ |link| context==:raw ? link : link.to_cardname.to_absolute(context) }
  end

  def item_type
    opt = options_card
    return nil if (!opt || opt==self)  #fixme, need better recursion prevention
    opt.item_type
  end

  def items=(array)
    self.content=''
    array.each {|i| self << i }
  end
  # FIXME.  this is horribly inefficient.  If there are 10 items in the array the card will get saved 10 times!

  def << card
    add_item case card
               when Card; card.name
               when Integer; c = Card[card] and c.name
               else card end
    self
  end

  def add_item newname
    inames = item_names
    unless inames.include? newname
      self.content="[[#{(inames << newname).reject(&:blank?)*"]]\n[["}]]"
      save!
    end
  end

  def drop_item name
    inames = item_names
    if inames.include? name
      inames = inames.reject{|n|n==name}
      self.content= inames.empty? ? '' : "[[#{inames * "]]\n[["}]]"
      save!
    end
  end

  def options_card
    card = self.rule_card :options
    (card && card.collection?) ? card : nil
  end

  def options
    (oc=self.options_card) ? oc.item_cards(:default_limit=>50) : Card.search(:sort=>'alpha',:limit=>50)
  end

  def option_text(option)
    name = self.rule(:options_label) || 'description'
    textcard = Card["#{option}+#{name}"]
    textcard ? textcard.content : nil
  end
end
