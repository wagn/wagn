require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths")) 

Given /^I log in as (.+)$/ do |user_card_name|
  # FIXME: define a faster simulate method?
  #webrat.automate do 
    user = Card[user_card_name].extension
    visit "/account/signin"
    fill_in("login", :with=> user.email )
    fill_in("password", :with=> user.login.split("_")[0]+"_pass")
    click_button("Sign me in")     
    response.should contain "My Card: #{user_card_name}"
  #end
end                                     

                   
Then /^In (.*) I should see "([^\"]*)"$/ do |section, text|
  within scope_of(section) do |scope|
    scope.should contain(text)
  end
end

When /^In (.*) I follow "([^\"]*)"$/ do |section, link|
  within scope_of(section) do |scope|
    scope.click_link link
  end
end

When /^In (.*) I click (.*)$/ do |section, control|
  # webrat.automate do
  #   within scope_of(section) do |scope|
  #     scope.click_link link
  #   end
  # end
  
  webrat.simulate do                      
    visit *params_for(control,section)
  end                                             
end