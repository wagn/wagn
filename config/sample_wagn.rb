
System.base_url = "http://localhost:3000"
System.site_name = "NeWagN"

System.max_render_time = 4.0
System.max_renders = 8

System.invitation_email_subject = "Join the {site_name} Community!"
System.invitation_email_body = "\nHello,\n{invitor} has invited you to join the {site_name} community.\n"

System.invite_request_alert_email = 'somebody@somewhere.com'

System.forgotinvitation_email_subject = "Activate your account at {site_name}"
System.forgotinvitation_email_body = "\nHello,\nYou clicked on forgot password," +
  "but you have not yet activated your account.\n" +
  "This message contains a link to activate your account.\n"

ExceptionNotifier.exception_recipients = %w(someone@somewhere.org)
ExceptionNotifier.sender_address = %("#{System.site_name} Error" <notifier@wagn.org>)
ExceptionNotifier.email_prefix = "[#{System.site_name}] "

# select a store for the rails/card cache
#ActionController::Base.fragment_cache_store = :mem_cache_store 
#                                              :memory_store 
#                                              :file_store, "#{RAILS_ROOT}/../cache"
