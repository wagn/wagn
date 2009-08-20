require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths")) 

Given /^(.*) (is|am) watching "([^\"]+)"$/ do |user, verb, cardname|   
  user = User.current_user.card.name if user == "I" 
  Given "the card #{cardname}+*watchers contains \"[[#{user}]]\"" 
end                         

Then /^(.*) should be notified that "(.*)"$/ do |username, subject|
  user = (username == "I") ? @current_user : Card[username].extension
  email = user.email
  begin
    Then %{"#{email}" should receive 1 email}
  rescue Spec::Expectations::ExpectationNotMetError=>e
    raise Spec::Expectations::ExpectationNotMetError, "#{e.message}\n Found the following emails:\n\n #{all_emails.to_s}" 
  end
  When %{"#{email}" opens the email with subject "#{subject}"}     
end

Then /^No notification should be sent$/ do  
  all_emails.should be_empty
end