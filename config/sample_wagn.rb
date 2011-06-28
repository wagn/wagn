module Wagn::Local
  # Leave this on the sample_wagn.rb file only
  def self.included(base)
    self.local(base)
    System.base_url.gsub!(/\/$/,'')
    Wagn::Cache.initialize_on_startup
  end

  # Override this in config/wagn.rb
  def self.local(base)
    # Really local stuff here in config/wagn.rb
    base.base_url = "http://localhost:3000/"

    base.max_renders = 8

    ExceptionNotifier.exception_recipients = ['person1@website.org','person2@website.org']
    ExceptionNotifier.sender_address       = '"Wagn Error" <notifier@wagn.org>'
    ExceptionNotifier.email_prefix         = "[Wagn]"
  end
end
