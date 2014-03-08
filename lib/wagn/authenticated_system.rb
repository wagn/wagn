# -*- encoding : utf-8 -*-
module Wagn::AuthenticatedSystem
  
  protected
  
  def logged_in?
    Account.logged_in?
  end

  # Accesses the current user from the session.
  def current_account_id
    @current_account_id ||= begin
      if card_id = session[:user]
        if Card.exists? card_id
          card_id
        else
          session[:user] = nil
        end
      end
    end
  rescue Exception => e
    session[:user] = nil
    raise e
  end

  # Store the given user in the session.
  def current_account_id= card_id
    @current_account_id = session[:user] = card_id
  end


  # Inclusion hook to make #current_account_id and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    super
    base.send :helper_method, :current_account_id, :logged_in?
  end
end
