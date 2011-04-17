# Project-specific configuration for CruiseControl.rb

begin
require 'config/wagn_cruise.rb'
rescue LoadError
end

class WagnCruise
end

Project.configure do |project|
  
  # Send email notifications about broken and fixed builds to email1@your.site, email2@your.site (default: send to nobody)
  project.email_notifier.emails = WagnCruise.respond_to?(:email_list) ?
     WagnCruise.email_list : ['gerryg@inbox.com']

  # Build the project by invoking rake task 'custom'
  # project.rake_task = 'custom'

  # Build the project by invoking shell script "build_my_app.sh".
  # We copy build_wagn.sh up from the root .cruise dir
  project.build_command = './script/build_wagn.sh'

  # Ping Subversion for new revisions every 5 minutes (default: 30 seconds)
  # project.scheduler.polling_interval = 5.minutes

end
