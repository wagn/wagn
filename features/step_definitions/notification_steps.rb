require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^(.*) (is|am) watching "([^\"]+)"$/ do |user, verb, cardname|
  user = Account.user_card.name if user == "I"
  step "the card #{cardname}+*watchers contains \"[[#{user}]]\""
end

Then /^(.*) should be notified that "(.*)"$/ do |username, subject|
  user = User.where(:card_id=>(username == "I") ? @session_id : Card[username].id).first
  email = user.email
  begin
    step %{"#{email}" should receive 1 email}
  rescue RSpec::Expectations::ExpectationNotMetError=>e
    raise RSpec::Expectations::ExpectationNotMetError, "#{e.message}\n Found the following emails:\n\n #{all_emails.to_s}"
  end
  open_email(email, :with_subject => /#{subject}/)
end

Then /^No notification should be sent$/ do
  all_emails.should be_empty
end
