module AuthenticatedSystem
  protected
  def logged_in?
    current_<%= file_name %>
  end

  # Accesses the current <%= file_name %> from the session.
  def current_<%= file_name %>
    @current_<%= file_name %> ||= session[:<%= file_name %>] ? <%= class_name %>.find_by_id(session[:<%= file_name %>]) : nil
  end

  # Store the given <%= file_name %> in the session.
  def current_<%= file_name %>=(new_<%= file_name %>)
    session[:<%= file_name %>] = new_<%= file_name %>.nil? ? nil : new_<%= file_name %>.id
    @current_<%= file_name %> = new_<%= file_name %>
  end

  # Check if the <%= file_name %> is authorized.
  #
  # Override this method in your controllers if you want to restrict access
  # to only a few actions or if you want to check if the <%= file_name %>
  # has the correct rights.
  #
  # Example:
  #
  #  # only allow nonbobs
  #  def authorize?(<%= file_name %>)
  #    <%= file_name %>.login != "bob"
  #  end
  def authorized?(<%= file_name %>)
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

    # Check if <%= file_name %> is logged in and authorized
    return true if logged_in? and authorized?(current_<%= file_name %>)

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
  # behavior in case the <%= file_name %> is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied
    redirect_to :controller => '/<%= controller_file_name %>', :action => 'login'
  end  

  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.request_uri
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end

  # Inclusion hook to make #current_<%= file_name %> and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :current_<%= file_name %>, :logged_in?
  end
end
