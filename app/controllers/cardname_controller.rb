class CardnameController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card
end
