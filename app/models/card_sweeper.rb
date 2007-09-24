class CardSweeper < ActionController::Caching::Sweeper
  observe Card::Base

  def after_save(card)   
    File.open("/tmp/fucker", "a") {|f| f.write "RUNNING THE CARD FUCKING SWEEPER\n"}
    
    expire_card(card)

    # FIXME: this will need review when we do the new defaults/templating system
    #if card.updates.for?(:content)
      card.hard_templatees.each {|c| expire_card(c) }     
      card.transcluders.each {|c| expire_card(c) }
    #end
    
    #if card.updates.for?(:name)
      card.dependents.each {|c| expire_card(c) }
      card.referencers.each {|c| expire_card(c) }
      card.name_references.plot(:referencer).each{|c| expire_card(c)}
    #end

    
    #if card.type=='Cardtype' 
      session[:createable_cardtypes] = User.current_user.createable_cardtypes
   # end
  end
  
  private
  def expire_card(c)
    #expire_fragment("card/view/#{c.id}")
    expire_fragment("card/line/#{c.id}")   
    expire_fragment("card/content/#{c.id}")   
  end
  
end
