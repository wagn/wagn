require "action_mailer"

ActionController::Base.class_eval do
  append_view_path File.dirname(__FILE__) + '/lib/../views'
end
