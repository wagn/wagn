System.base_url = "http://localhost:3000"

System.max_renders = 8

ExceptionNotifier.exception_recipients = ['person1@website.org','person2@website.org']
ExceptionNotifier.sender_address       = '"Wagn Error" <notifier@wagn.org>'
ExceptionNotifier.email_prefix         = "[Wagn]"

CachedCard.set_cache_prefix "#{System.host}/#{RAILS_ENV}"


# select a store for the rails/card cache
#ActionController::Base.cache_store = :mem_cache_store 
#                                     :memory_store 
#                                     :file_store, "#{RAILS_ROOT}/../cache"

