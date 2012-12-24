require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I log in as (.+)$/ do |user_card_name|
  # FIXME: define a faster simulate method ("I am logged in as")
  @session_user = ucid = Card[user_card_name].id
  user_object = User.where(:card_id=>ucid).first
  visit "/account/signin"
  fill_in("login", :with=> user_object.email )
  fill_in("password", :with=> user_object.login.split("_")[0]+"_pass")
  click_button("Sign me in")
  page.should have_content(user_card_name)
end

Given /^I log out/ do
  visit "/"
  click_link("Sign out")
  page.should have_content("Sign in")
end

Given /^the card (.*) contains "([^\"]*)"$/ do |cardname, content|
  Account.as_bot do
    card = Card.fetch_or_create cardname
    card.content = content
    card.save!
  end
end

When /^(.*) edits? "([^\"]*)"$/ do |username, cardname|
  logged_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
  end
end

When /^(.*) edits? "([^\"]*)" entering "([^\"]*)" into wysiwyg$/ do |username, cardname, content|
  logged_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
    page.execute_script "$('#main .card-content').val('#{content}')"
    click_button("Submit")
  end
end


When /^(.*) edits? "([^\"]*)" setting (.*) to "([^\"]*)"$/ do |username, cardname, field, content|
  logged_in_as(username) do 
    visit "/card/edit/#{cardname.to_name.url_key}"
    fill_in 'card[content]', :with=>content 
    click_button("Submit")
  end
end

When /^(.*) edits? "([^\"]*)" with plusses:/ do |username, cardname, plusses|
  logged_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
    plusses.hashes.first.each do |name, content|
      fill_in "card[cards][#{(cardname+'+'+name).to_name.pre_cgi}][content]", :with=>content
    end
    click_button("Submit")
  end
end

When /^(.*) creates?\s*a?\s*([^\s]*) card "(.*)" with content "(.*)"$/ do |username, cardtype, cardname, content|
  create_card(username, cardtype, cardname, content) do
    fill_in("card[content]", :with=>content)
  end
end

When /^(.*) creates?\s*a?\s*([^\s]*) card "(.*)" with content$/ do |username, cardtype, cardname, content|
  create_card(username, cardtype, cardname, content) do
    fill_in("card[content]", :with=>content)
  end
end

When /^(.*) creates?\s*([^\s]*) card "([^"]*)"$/ do |username, cardtype, cardname|
  create_card(username,cardtype,cardname)
end

When /^(.*) creates?\s*([^\s]*) card "([^"]*)" with plusses:$/ do |username,cardtype,cardname,plusses|
  create_card(username,cardtype,cardname) do
    plusses.hashes.first.each do |name, content|
      fill_in "card[cards][~plus~#{name}][content]", :with=>content
    end
  end
end

When /^(.*) deletes? "([^\"]*)"$/ do |username, cardname|
  logged_in_as(username) do
    visit "/card/delete/#{cardname.to_name.url_key}"
  end
end

When /I wait a sec/ do
  sleep 1
end

Then /what/ do
  save_and_open_page
end

Then /debug/ do
  debugger
end


def create_card(username,cardtype,cardname,content="")
  logged_in_as(username) do
    if cardtype=='Pointer'
      Card.create :name=>cardname, :type=>cardtype, :content=>content
    else
      visit "/card/new?card[name]=#{CGI.escape(cardname)}&type=#{cardtype}"
      yield if block_given?
      click_button("Submit")
    end
  end
end

def logged_in_as(username)
  sameuser = (username == "I" or @session_user && Card[@session_user].name == username)
  unless sameuser
    @saved_user = @session_user
    step "I log in as #{username}"
  end
  yield
  unless sameuser
    step( @saved_user ? "I log in as #{Card[@saved_user].name}" : "I log out" )
  end
end


When /^In (.*) I follow "([^\"]*)"$/ do |section, link|
  within scope_of(section) do
    click_link link
  end
end

When /^In (.*) I click "(.*)"$/ do |section, link|
  within scope_of(section) do
    click_link link
  end
end

When /^I hover over the main menu$/ do
  page.execute_script "$('#main > .card-slot .card-header > .card-menu-link').trigger('mouseenter')"
end

Then /the card (.*) should contain "([^\"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("the main card content") do
    page.should have_content(content)
  end
end

Then /the card (.*) should not contain "([^\"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("the main card content") do
    page.should_not have_content(content)
  end
end

Then /^In (.*) I should see "([^\"]*)"$/ do |section, text|
  within scope_of(section) do
    page.should have_content(text)
  end
end

Then /^In (.*) I should not see "([^\"]*)"$/ do |section, text|
  within scope_of(section) do
    page.should_not have_content(text)
  end
end

Then /^In (.*) I should (not )?see a ([^\"]*) with class "([^\"]*)"$/ do |selection, neg, element, selector|
  # checks for existence of a element with a class in a selection context
  element = 'a' if element == 'link'
  within scope_of(selection) do
    page.send ( neg ? :should_not : :should ), have_css( [ element, selector ] * '.' )
  end
end

Then /^the "([^"]*)" field should contain "([^"]*)"$/ do |field, value|
  field_labeled(field).value.should =~ /#{value}/
end

Then /^"([^"]*)" should be selected for "([^"]*)"$/ do |value, field|
  field_labeled(field).element.search(".//option[@selected = 'selected']").inner_html.should =~ /#{value}/
end

## variants of standard steps to handle """ style quoted args
Then /^I should see$/ do |text|
  page.should have_content(text)
end

When /^I fill in "([^\"]*)" with$/ do |field, value|
  fill_in(field, :with => value)
end

