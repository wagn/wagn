class TransclusionController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card, :except=>[:create]
#  before_filter :edit_ok, :except=>[:edit]
  layout :ajax_or_not
   
  def view 
    @action='transclusion'
    render :text=>render_view
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
    @wrap = true  
    if params[:requested_view] == 'edit'
      edit_screen = render_to_string( :inline=>%{<%= get_slot.render(:edit_transclusion) %>} )
    else
      edit_screen = render_to_string :action=>'edit'
    end
    render_update_slot do |page,target|
      target.replace edit_screen
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
    view_screen = render_view
    render_update_slot do |page,target|
      target.replace view_screen
    end
  end  

  private
  def render_view
    @render_key = {
      "card" => :view,
      "line" => :line,
      "content" => :content,
      "edit"  => :edit_transclusion
    }[params[:requested_view]] || :content
    render_to_string :inline=>%{<%= get_slot.render(@render_key, :wrap=>false, :add_javascript=>true) %>}
  end
end
