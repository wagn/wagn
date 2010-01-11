module Devise # will be Account
  module Controllers
    # Create url helpers to be used with resource/scope configuration. Acts as
    # proxies to the generated routes created by devise.
    # Resource param can be a string or symbol, a class, or an instance object.
    # Example using a :user resource:
    #
    #   new_session_path(:user)      => new_user_session_path
    #   session_path(:user)          => user_session_path
    #   destroy_session_path(:user)  => destroy_user_session_path
    #
    #   new_password_path(:user)     => new_user_password_path
    #   password_path(:user)         => user_password_path
    #   edit_password_path(:user)    => edit_user_password_path
    #
    #   new_confirmation_path(:user) => new_user_confirmation_path
    #   confirmation_path(:user)     => user_confirmation_path
    #
    # Those helpers are added to your ApplicationController.

    module UrlHelpers
      action_map = {
        :session => { :new => :signin, :destry => :signout, :blank => :new },
        :password => { :edit => :update, :new => :signup, :blank => :new },
        :confirmation => { :new => :invite, :blank => :accept  }, #
      }
      [:session, :password, :confirmation].each do |module_name|
        [:path, :url].each do |path_or_url|
          actions = action_map[module_name]
          actions.each do |action, myaction|
            class_eval <<-URL_HELPERS
              def #{action}#{module_name}_#{path_or_url}(resource, *args)
                resource = case resource
                  when Symbol, String
                    resource
                  when Class
                    resource.name.underscore
                  else
                    resource.class.name.underscore
                end

                send("#{myaction}\#{resource}_#{module_name}_#{path_or_url}", *args)
              end
            URL_HELPERS
          end
        end
      end

    end
  end
end
