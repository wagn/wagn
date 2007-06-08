class CardSweeper < ActionController::Caching::Sweeper
  observe Card::Base

  def after_save(card)               
    expire_card(card)
    card.referencers.each {|c| expire_card(c) }
    card.templatees.each {|c| expire_card(c) }     
    card.tag.cards.each {|c| expire_card(c) }
  end
  
  private
  def expire_card(c)
    expire_fragment("card/view/#{c.id}")   
  end
  
end
