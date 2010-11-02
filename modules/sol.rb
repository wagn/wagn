module Sol
  protected

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

  def self.included(base)
    #base.send :helper_method, :has_sol?
    Card.add_extension_tag('*sol', [:declare])
  end

  def has_sol?() true if solcard end  
  def solcard() extcard('*sol') end
end

CardController.class_eval do
  #----------------( Posting Currencies to Cards )
  def declare
    id = Cardname.unescape(params['id'] || '')
    raise("Need a card to receive declarations") if (id.nil? or id.empty?)
    if @card = Card.find_by_id(id)
    Rails.logger.info("Declare #{@card && @card.name} #{@card && @card.inspect}")
      if @card.has_ext?('*sol')
        Rails.logger.info("Declare render it "+@card.name)
        if ['name'].member?(params[:attribute])
          render :partial=>"card/declare/#{params[:attribute]}" 
        end
      else
        raise "no sol? #{@card && @card.name}"
      end
    end
  end
end

Card.send :include, Sol

