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

Given /^the card (.*) contains "([^\"]*)"$/ do |cardname, content|
  webrat.simulate do
    User.as(:wagbot) do
      card = Card.find_or_create! :name=>cardname
      card.content = content
      card.save!
    end
  end
end
         
Given /^the pointer (.*) contains "([^\"]*)"$/ do |cardname, content|
  webrat.simulate do
    Given "the card #{cardname} contains \"#{content}\"" 
  end
end

When /the page updates/ do
  webrat.simulate do
    visit '/wagn/Home'
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
     
Then /the card (.*) should contain "([^\"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("the main card content") do |scope|
    scope.should contain(content)
  end
end

Then /the card (.*) should not contain "([^\"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("the main card content") do |scope|
    scope.should_not contain(content)
  end
end


Then /^In (.*) I should see "([^\"]*)"$/ do |section, text|
  within scope_of(section) do |scope|
    scope.should contain(text)
  end
end


Then /^In (.*) I should not see "([^\"]*)"$/ do |section, text|
  within scope_of(section) do |scope|
    scope.should_not contain(text)
  end
end
