class TransclusionController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card, :edit_ok

  def view
    render :update do |page|  
      # FIXME do they all have cardname? view, line, etc.
      page.select("span[cardid=#{@card.id}]").all() do |elem,index|
        elem.update rendered_content(@card)
      end
      page << "setupCardViewStuff()"
    end
  end  
  
  def edit
    edit_screen = render_to_string :action=>'edit'
    render :update do |page|
      page.select(slot.selector).all() do |elem, index|
        elem.update edit_screen
      end
    end
  end
     
  def create  
    @card = Card.create params[:card]
    return render_errors(@card) unless @card.errors.empty? 
    # FIXME: a ton of this is duplicated in edit
    edit_screen = render_to_string :action=>'edit'
    render :update do |page|
      page.select(slot.selector).all() do |elem, index|
        elem.replace %{<span class="editOnDoubleClick" position="#{slot.position}" cardid="#{@card.id}">} +  
          edit_screen + "</span>"
      end
      page.replace_html slot.id(:notice), "CREATED #{params[:card][:name]}"
      page << "setupCardViewStuff()"
    end
  end
  
  def update 
    @card.update_attributes params[:card]     
    return render_errors(@card) unless @card.errors.empty?
    view
  end
end
