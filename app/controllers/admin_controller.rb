# -*- encoding : utf-8 -*-
class AdminController < ApplicationController
  layout 'application'

  def setup
    Wagn::Cardname #loading oddity made this necessary in dev.  pls don't remove without testing setup.
    
    raise(Wagn::Oops, "Already setup") unless Session.no_logins? && !User[:first]
    Wagn::Conf[:recaptcha_on] = false
    if request.post?
      #Card::User  # wtf - trigger loading of Card::User, otherwise it tries to use U
      Session.as_bot do
        @account, @card = User.create_with_card( params[:account].merge({:login=>'first'}), params[:card] )
        set_default_request_recipient

        #warn "ext id = #{@account.id}"

        if @account.errors.empty?
          roles_card = Card.fetch_or_new(@card.cardname.trait_name(:roles))
          roles_card.content = "[[#{Card[Card::AdminID].name}]]"
          roles_card.save
          self.session_user = @card
          Card.cache.delete 'no_logins'
          flash[:notice] = "You're good to go!"
          redirect_to Card.path_setting('/')
        else
          flash[:notice] = "Durn, setup went awry..."
        end
      end
    else
      @card = Card.new( params[:card] || {} ) #should prolly skip defaults
      @account = User.new( params[:user] || {} )
    end
  end
  
  def show_cache
    key = params[:id].to_cardname.to_key
    @cache_card = Card.fetch(key)
    @db_card = Card.find_by_key(key)
  end
  
  def clear_cache
    response = 
      if Session.always_ok?
        Wagn::Cache.reset_global
        'Cache cleared'
      else
        "You don't have permission to clear the cache"
      end
    render :text =>response, :layout=> true  
  end

  private
  
  def set_default_request_recipient
    to_card = Card.fetch_or_new('*request+*to')
    to_card.content=params[:account][:email]
    to_card.save
  end

end
