class TransclusionController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card, :edit_ok   
  layout :ajax_or_not
   
  def view 
    @action='transclusion'
    render :partial => 'view', :locals=>{ :card=>@card }, :layout=>ajax_or_not
  end
   

=begin
  def view
    render :update do |page|  
      # FIXME do they all have cardname? view, line, etc.
      page.select("span[cardid=#{@card.id}]").all() do |elem,index|
        elem.update slot.rendered_content(@card)
      end
      page << "setupCardViewStuff()"
    end
  end  
=end

=begin  
  def edit
    edit_screen = render_to_string :action=>'edit'
    render :update do |page|
      page.select(slot.selector).all() do |elem, index|
        elem.update edit_screen
      end
    end
  end
=end
     
  def create  
    @card = Card.create params[:card]
    return render_errors(@card) unless @card.errors.empty? 
    # FIXME: a ton of this is duplicated in edit
    edit_screen = render_to_string :action=>'edit'
    render_update_slot do |page,target|
      target.update edit_screen           
      # FIXME: this probably needs to set more than just cardid
      page << %{value.attributes['cardid'].value = '#{@card.id}'}
      # FIXME: not sure how to get the containing slot here..
      page.replace_html 'alerts', "CREATED #{params[:card][:name]}"
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
    render_update_slot_element 'content', render_to_string(:partial => "view", :locals=>{ :card=>@card }, :layout=>ajax_or_not )
  end
end
