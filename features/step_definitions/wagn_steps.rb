require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths")) 

Given /^I log in as (.+)$/ do |user_card_name|
  user = Card[user_card_name].extension
  visit "/account/signin"
  fill_in("login", :with=> user.email )
  fill_in("password", :with=> user.login.split("_")[0]+"_pass")
  click_button("Sign me in")     
  response.should contain "My Card: #{user_card_name}"
end                                     

                   
