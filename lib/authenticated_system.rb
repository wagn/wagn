module AuthenticatedSystem
  protected
  def logged_in?() Session.user_id && Session.logged_in? end

  # Accesses the current user from the session.
  def session_user
    @session_user ||= session[:user]
  rescue Exception => e
    #warn "except #{e.inspect}, #{e.backtrace*"\n"}"
    session[:user] = nil
    raise e
  end

  # Store the given user in the session.
  def session_user=(new_user)
    @session_user = session[:user] = Card==new_user ? card.id : new_user
  end

  # Check if the user is authorized.
  #
  # Override this method in your controllers if you want to restrict access
  # to only a few actions or if you want to check if the user
  # has the correct rights.
  #
  # Example:
  #
  #  # only allow nonbobs
  #  def authorize?(user)
  #    user.login != "bob"
  #  end
  def authorized?(user)
     true
  end

  # Check whether or not to protect an action.
  #
  # Override this method in your controllers if you only want to protect
  # certain actions.
  #
  # Example:
  #
  #  # don't protect the login and the about method
  #  def protect?(action)
  #    if ['action', 'about'].include?(action)
  #       return false
  #    else
  #       return true
  #    end
  #  end
  def protect?(action)
    true
  end

  # Filter method to enforce a login requirement.
  #
  # To require logins for all actions, use this in your controllers:
  #
  #   before_filter :login_required
  #
  # To require logins for specific actions, use this in your controllers:
  #
  #   before_filter :login_required, :only => [ :edit, :update ]
  #
  # To skip this in a subclassed controller:
  #
  #   skip_before_filter :login_required
  #
  def login_required
    # Skip this filter if the requested action is not protected
    return true unless protect?(action_name)

    # Check if user is logged in and authorized
    return true if logged_in? and authorized?(session_user)

    # Store current location so that we can redirect back after login
    store_location
    

    # Call access_denied for an appropriate redirect and stop the filter
    # chain here
    access_denied and return false
  end

  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied
    wagn_redirect( Wagn::Conf[:base_url] + url_for(:controller=>'account', :action=>'signin') )
  end  

  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.fullpath
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to(session[:return_to]) : 
      (default.nil? ? redirect_to('/') : redirect_to(default))
    session[:return_to] = nil
  end

  # Inclusion hook to make #session_user and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    super
    base.send :helper_method, :session_user, :logged_in?
  end
end
