require "ruby-debug"

module ActionController::Routing
  class RouteSet #:nodoc:
    # Ensure Devise modules are included only after loading routes, because we
    # need devise_for mappings already declared to create magic filters and
    # helpers.
    def load_routes_with_user!
      load_routes_without_user!
      return if Devise.mappings.empty?
    
      #ActionController::Base.send :include, User::Controllers::Filters
      ActionController::Base.send :include, User::Controllers::UrlHelpers
    
      ActionView::Base.send :include, User::Controllers::UrlHelpers
rescue Exception => e
debugger
raise e
    end
    alias_method_chain :load_routes!, :user
  end
end

