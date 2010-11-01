module Sol
  protected
  EXTENSION_CARD = '*sol'

  def receive_breath
    @card ||= Card.new(params[:card])
    if has_sol? and !breath_in(:model=>@card)
      render_card_errors(@card)
      return false
    end
    true
  end                  
  
  def breath_in
    opts = {
      :model => @card,
    }.merge(args)
    breath(opts) 
  end

  def has_sol?(card=nil)
    card ||= @card
    solcard = Card[card.name+JOINT+EXTENSION_CARD]
#Rails.logger.info("has_sol: #{card && card.name} : #{solcard && solcard.name}")
    true if solcard
  end  
  
  def self.included(base)
    Card.add_extension_tag(EXTENSION_CARD, [:declare])
  end
end

CardController.class_eval do
  #----------------( Posting Currencies to Cards )
  def declare
    id = Cardname.unescape(params['id'] || '')
    raise("Need a card to receive declarations") if (id.nil? or id.empty?)
    @card = Card.find_by_id(id)
    Rails.logger.info("Declare #{@card.name} #{@card.inspect}")
    if has_sol?
      Rails.logger.info("Declare render it "+@card.name)
      if ['name'].member?(params[:attribute])
        render :partial=>"card/declare/#{params[:attribute]}" 
      end
    else
      raise "no sol?"
    end
  end

end
  
Card.send :include, Sol
