module Card
  class Pointer < Base

    def collection?() true  end

    def item_cards( args={} )
      item_names(args).map {|name| Card.fetch(name) }.compact
    end

    def item_names( args={} )
      context = args[:context]
      links = content.split(/\n+/).map{ |x| x.gsub(/\[\[|\]\]/,'')}.map{|x|
        context ? x.to_absolute(context) : x
      }
    end

    def first
      item_names.first
    end

    def add_item( cardname )
      unless item_names.include? cardname
        self.content = (item_names + [cardname]).reject{|x|x.blank?}.map{|x| "[[#{x}]]" }.join("\n")
        save!
      end
    end 
                                  
    def drop_item( cardname ) 
      if item_names.include? cardname
        self.content = (item_names - [cardname]).map{|x| "[[#{x}]]"}.join("\n")
        save!
      end
    end
    
    def item_type
      opt = options_card
      opt ? opt.spec[:type] : nil
    end
    
    def options_card
      card = self.setting_card('options')
      (card && card.collection?) ? card : nil
    end

    def options(limit=50)
      (oc=self.options_card) ? oc.item_cards(:limit=>limit) : Card.search(:sort=>'alpha',:limit=>limit)
    end

    def option_text(option)
      name = setting('option label') || 'description'
      textcard = Card.fetch(option+'+'+name, :skip_virtual => true)
      textcard ? textcard.content : nil
    end
  end
end
