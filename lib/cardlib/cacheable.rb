module Cardlib
  module Cacheable
    def hard_template?
      extension_type =='HardTemplate'
    end

    def soft_template?
      !hard_template?
    end

	  def pointees
	    User.as(:wagbot) do
  	    links = content.split(/\n+/).map{ |x| x.gsub(/\[\[|\]\]/,'')}
	    end
	  end
	  
	  def pointee
	    pointees.first
    end    
    
    # FIXME: maybe this should be methods in individual classes?
    def list_items context = nil
      case self.type
      when "Pointer"
        self.pointees
      when "Search"
        self.list_cards(context).map {|card| card.name }
      else
        self.content.split(/[,\n]/)
      end
    end
    
    def list_cards context = nil
      case self.type
      when "Pointer";
        self.list_items.map{|cardname| CachedCard.get( cardname ) }
      when "Search";
        self.search(:limit => "", :_card=>(context ? context : self))
      else
        [self]
      end
    end
    
    def extended_list context = nil
      # this could go on and on..
      self.list_cards(context).map{|x| x.list_cards }.flatten.map{|x| x.list_items }.flatten
    end
    
    def contextual_content context = nil
      context ||= self
      User.as :wagbot do
        context.content = self.content
      end
      s=Slot.new(context);
      # FIXME: maybe slot.rb should have an additional view for this.
      # ultimately we need to be able to process links and inclusions in an email/text friendly way
      s.expand_inclusions(s.render(:naked_content))
    end

    
  end
end