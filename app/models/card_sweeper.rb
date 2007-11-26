class CardSweeper < ActionController::Caching::Sweeper
  observe Card::Base

  def after_save(card) 
    return if card.nil?  #FIXME: this happens on create-- why???  
    expire(card)
     
    # FIXME: this will need review when we do the new defaults/templating system
    if card.changed?(:content)
      card.hard_templatees.each {|c| expire(c) }     
      card.transcluders.each {|c| expire(c) }
    end
    
    if card.changed?(:name)      
      card.dependents.each {|c| expire(c) }
      card.referencers.each {|c| expire(c) }
      card.name_references.plot(:referencer).each{|c| expire(c)}
    end
  end
  
  private  
  
  def expire(card)
    CachedCard.new(card.key).expire_all
  end
  
end
