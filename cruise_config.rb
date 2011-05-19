# Project-specific configuration for CruiseControl.rb

Project.configure do |project|
  
  # Send email notifications about broken and fixed builds to email1@your.site, email2@your.site (default: send to nobody)
  # project.email_notifier.emails = ['email1@your.site', 'email2@your.site']

  # Build the project by invoking rake task 'custom'
  # project.rake_task = 'custom'

  # Build the project by invoking shell script "build_my_app.sh".
  # We copy build_wagn.sh up from the root .cruise dir
  project.build_command = './script/build_wagn.sh'

  # Ping Subversion for new revisions every 5 minutes (default: 30 seconds)
  # project.scheduler.polling_interval = 5.minutes
end


# Using cruise with Wagn:
#
# 1. You can override settings in this cruise_config.rb file in [cruise data]/projects/your_project/cruise_config.rb
# 2. You should set up database.yml content in files that follow this pattern:  config/cruise.[name].database.yml
# 3. You should set up wagn.rb content in a file named config/cruise.wagn.rb
# 4. By default the databases are not regenerated from scratch each time you run the integration tests.  
#    To trigger re-creation, you will need to remove config/wagn.rb

