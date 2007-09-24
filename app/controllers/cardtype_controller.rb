class CardtypeController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
 # layout :ajax_or_not
  before_filter :load_card, :edit_ok
end

