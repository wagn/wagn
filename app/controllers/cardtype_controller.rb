class CardtypeController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card, :edit_ok
  
  def update
    if @card.update_attributes params[:card]
      render :action=>'view'
end
