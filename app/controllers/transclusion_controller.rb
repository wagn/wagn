class TransclusionController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card
#  before_filter :edit_ok, :except=>[:edit]
  layout :ajax_or_not
   
  def view 
    @action='transclusion'
    render :partial => 'view', :locals=>{ :card=>@card }, :layout=>ajax_or_not
  end
   
  def create  
    if !Card.new(params[:card]).cardtype.ok?(:create)
      @no_slot_header = true
      msg = render_to_string( :template=>'/card/denied', :status=>403 )
      render_update_slot do |page,target|
        target.replace(slot.head + msg + slot.foot)
      end
      return
    end

    @card = Card.create! params[:card]
    # FIXME: a ton of this is duplicated in edit
    @action='transclusion'  # get the right css in the slot
    edit_screen = render_to_string :action=>'edit'
    render_update_slot do |page,target|
      target.replace slot.head + edit_screen + slot.foot
      # FIXME: this probably needs to set more than just cardid
      #page << %{value.attributes['cardid'].value = '#{@card.id}'}
      
      # FIXME: would be nice to have this alert closer to the edit location
      page.replace_html 'alerts', "CREATED #{params[:card][:name]}"
    end
  end
  
  def edit
    #return render(:text=>"",:status=>403) unless @card.ok?(:edit)
    if !@card.ok?(:edit)  
      @no_slot_header = true
      return render( :template=>'/card/denied')
    end
  end
  
  
  def update 
    # FIXME: this code is same as card_controller
    if @card.hard_content_template
      errors = false
      params[:cards].each_pair do |id, opts|
        card = Card.find(id)
        card.update_attributes(opts)
        if !card.errors.empty?
          card.errors.each do |field, err|
            @card.errors.add card.name, err
          end
        end
      end
    else
      @card.update_attributes! params[:card]     
    end
    view_screen = render_to_string(:partial => "view", :locals=>{ :card=>@card }, :layout=>ajax_or_not )
    render_update_slot do |page,target|
      target.update view_screen
      page << %{Wagn.lister().update( {onComplete: function(){
         new Effect.Highlight($$("span[cardid=#{@card.id}]")[0]); }}) \n }
    end
  end
end
