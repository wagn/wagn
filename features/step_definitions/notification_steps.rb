# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^(.*) (is|am) watching "([^\"]+)"$/ do |user, verb, cardname|
  user = Account.current.name if user == "I"
  Account.as Card[user] do
    step "the card #{cardname}+*watchers contains \"[[#{user}]]\""
  end
end

Then /^(.*) should be notified that "(.*)"$/ do |username, subject|
  card_with_acct = username=='I' ? Account.current : Card[username]
  email = card_with_acct.account.email

  begin
    step %{"#{email}" should receive 1 email}
  rescue RSpec::Expectations::ExpectationNotMetError=>e
    raise RSpec::Expectations::ExpectationNotMetError, %(#{e.message}\n Found the following emails:\n\n #{all_emails*"\n\n~~~~~~~~\n\n"})
  end
  open_email(email, :with_subject => /#{subject}/)
end

Then /^No notification should be sent$/ do
  all_emails.should be_empty
end
