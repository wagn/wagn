class CardnameController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card, :edit_ok    
  
  def update
    @old_card = @card.clone
    if @card.update_attributes params[:card]
      render :action=>'view'
    elsif @card.errors.on(:confirmation_required) && @card.errors.map {|e,f| e}.uniq.length==1
      @confirm = true   
      @card.confirm_rename=true
      @card.update_link_ins = true
      render :action=>'edit', :status=>200
    else          
      # don't report confirmation required as error in a case where the interface will let you fix it.
      @card.errors.instance_variable_get('@errors').delete('confirmation_required')
      @request_type='html'
      render_card_errors(@card)
    end
  end

=begin
  def confirm
    @action = 'confirm'
    if params[:card] and name=params[:card][:name]
      @card.name = name
    end
    render :action=>'edit'
  end
=end

end
