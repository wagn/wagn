class CardnameController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card, :edit_ok    
  
  def confirm
    @action = 'confirm'
    if params[:card] and name=params[:card][:name]
      @card.name = name
    end
    render :template=>'cardname/edit'
  end
end
