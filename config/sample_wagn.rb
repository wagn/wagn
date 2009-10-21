System.base_url = "http://localhost:3000"

System.max_renders = 8

ExceptionNotifier.exception_recipients = ['person1@website.org','person2@website.org']
ExceptionNotifier.sender_address       = '"Wagn Error" <notifier@wagn.org>'
ExceptionNotifier.email_prefix         = "[Wagn]"

CachedCard.set_cache_prefix "#{System.host}/#{RAILS_ENV}"

ActiveSupport::Dependencies.load_paths << "#{RAILS_ROOT}/app/addons"

