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
    base.send :helper_method, :has_sol?
    Card.add_extension_tag('*sol', [:declare])
  end
end

CardController.class_eval do
  #----------------( Posting Currencies to Cards )
  def declare
    id = Cardname.unescape(params['id'] || '')
    raise("Need a card to receive declarations") if (id.nil? or id.empty?)
    if @card = Card.find_by_id(id)
    Rails.logger.info("Declare #{@card && @card.name} #{@card && @card.inspect}")
      if @card.has_sol?
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

Card::Base.class_eval do
  def has_sol?
    #if self
      solcard = Card[name+JOINT+'*sol']
Rails.logger.info("has_sol: #{name} : #{solcard && solcard.name}")
      true if solcard
    #end
  end  
end

Slot.class_eval do
  def declare_submenu(on)
    div(:class=>'submenu') do
      [[ :content,    true  ],
       [ :name,       true, ],
       ].map do |key,ok,args|

        link_to_remote( key, 
          { :url=>url_for("card/declare", args, key), :update => ([:name].member?(key) ? id('card-body') : id) }, 
          :class=>(key==on ? 'on' : '') 
        ) if ok
      end.compact.join       
     end  
  end
end

CardController.send :include, Sol

