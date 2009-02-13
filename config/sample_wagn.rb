System.base_url = "http://localhost:3000"

System.max_render_time = 4.0
System.max_renders = 8

ExceptionNotifier.exception_recipients = ['person1@website.org','person2@website.org']
ExceptionNotifier.sender_address       = '"Wagn Error" <notifier@wagn.org>'
ExceptionNotifier.email_prefix         = "[Wagn]"



# select a store for the rails/card cache
#ActionController::Base.cache_store = :mem_cache_store 
#                                     :memory_store 
#                                     :file_store, "#{RAILS_ROOT}/../cache"



#STARRY:  don't stop until this is cleaned up and documented.

# GOING AWAY:


=begin
System.invitation_email_subject = "Join the {site_title} Community!"
System.invitation_email_body = "\nHello,\n{invitor} has invited you to join the {site_title} community.\n"
#System.site_title = "NeWagN"
System.invite_request_alert_email = 'somebody@somewhere.com'
=end
