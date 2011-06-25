module Wagn::Local
  def self.included(base)
    base.base_url = "http://localhost:3000/"
    base.max_renders = 8

    ExceptionNotifier.exception_recipients = ['person1@website.org','person2@website.org']
    ExceptionNotifier.sender_address       = '"Wagn Error" <notifier@wagn.org>'
    ExceptionNotifier.email_prefix         = "[Wagn]"
  end
end
