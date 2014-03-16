# -*- encoding : utf-8 -*-
require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))


Given /^I sign up as "(.*)" with email "([^\"]*)" and password "([^\"]*)"$/ do |cardname, email, password|
  visit '/account/signup'
  fill_in 'card_name', :with=>cardname
#  save_and_open_page
  fill_in "card[subcards][+*account+*email][content]", :with=> email
  fill_in "card[subcards][+*account+*password][content]", :with=> password
  click_button 'Submit'
end

Given /^I sign in as (.+)$/ do |account_name|
  # FIXME: define a faster simulate method ("I am logged in as")
  accounted = Card[account_name]
  @current_id = accounted.id
  visit "/:signin"
  fill_in "card[subcards][+*email][content]", :with=> accounted.account.email
  fill_in "card[subcards][+*password][content]", :with=> 'joe_pass'
  click_button "Sign in"
  page.should have_content(account_name)
end

Given /^I log out/ do
  visit "/"
  click_link("Sign out")
  page.should have_content("Sign in")
end

Given /^the card (.*) contains "([^\"]*)"$/ do |cardname, content|
  Account.as_bot do
    card = Card.fetch cardname, :new=>{}
    card.content = content
    card.save!
  end
end

When /^(.*) edits? "([^\"]*)"$/ do |username, cardname|
  signed_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
  end
end

When /^(.*) edits? "([^\"]*)" entering "([^\"]*)" into wysiwyg$/ do |username, cardname, content|
  signed_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
    page.execute_script "$('#main .card-content').val('#{content}')"
    click_button("Submit")
  end
end


When /^(.*) edits? "([^\"]*)" setting (.*) to "([^\"]*)"$/ do |username, cardname, field, content|
  signed_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
    fill_in 'card[content]', :with=>content
    click_button("Submit")
  end
end

When /^(.*) edits? "([^\"]*)" with plusses:/ do |username, cardname, plusses|
  signed_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
    plusses.hashes.first.each do |name, content|
      fill_in "card[subcards][#{cardname}+#{name}][content]", :with=>content
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
      fill_in "card[subcards][+#{name}][content]", :with=>content
    end
  end
end

When /^(.*) deletes? "([^\"]*)"$/ do |username, cardname|
  signed_in_as(username) do
    visit "/card/delete/#{cardname.to_name.url_key}"
  end
end



Given /^(.*) (is|am) watching "([^\"]+)"$/ do |user, verb, cardname|
  user = Account.current.name if user == "I"
  Account.as Card[user] do
    step "the card #{cardname}+*watchers contains \"[[#{user}]]\""
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
  signed_in_as(username) do
    if cardtype=='Pointer'
      Card.create :name=>cardname, :type=>cardtype, :content=>content
    else
      visit "/card/new?card[name]=#{CGI.escape(cardname)}&type=#{cardtype}"
      yield if block_given?
      click_button("Submit")
    end
  end
end

def signed_in_as(username)
  sameuser = (username == "I" or @current_id && Card[@current_id].name == username)
  unless sameuser
    @saved_user = @current_id
    step "I sign in as #{username}"
  end
  yield
  unless sameuser
    step( @saved_user ? "I sign in as #{Card[@saved_user].name}" : "I log out" )
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
  page.execute_script "$('#main > .card-slot > .card-header > .card-menu-link').trigger('mouseenter')"
end


Then /the card (.*) should contain "([^\"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("main card content") do
    page.should have_content(content)
  end
end

Then /the card (.*) should not contain "([^\"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("main card content") do
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
    page.send( ( neg ? :should_not : :should ), have_css( [ element, selector ] * '.' ) )
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

