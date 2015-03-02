# -*- encoding : utf-8 -*-
require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

if RUBY_VERSION =~ /^2/
  require 'byebug'
else
  require 'debugger'
end


Given /^site simulates setup need$/ do
  Card::Auth.simulate_setup_need!
end

Given /^site stops simulating setup need$/ do
  Card::Auth.simulate_setup_need! false
  step 'I am signed out'
end
  
Given /^I am signed in as (.+)$/ do |account_name|
  accounted = Card[account_name]
  visit "/update/:signin?card[subcards][%2B*email][content]=#{accounted.account.email}&card[subcards][%2B*password][content]=joe_pass"
  #could optimize by specifying simple text success page
end

Given /^I am signed out$/ do
  visit "/"
  if page.has_content? "Sign out"
    step 'I follow "Sign out"'
  end
end

=begin
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
=end


Given /^the card (.*) contains "([^\"]*)"$/ do |cardname, content|
  Card::Auth.as_bot do
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

When /^(.*) edits? "([^\"]*)" filling in "([^\"]*)"$/ do |username, cardname, content|
  visit "/card/edit/#{cardname.to_name.url_key}"
  fill_in 'card[content]', :with=>content
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
    normal_textarea_card_type = ["JavaScript","CoffeeScript","HTML","CSS","SCS","Search"]
    if not normal_textarea_card_type.include? cardtype or not page.evaluate_script "typeof ace != 'undefined'"
      fill_in("card[content]", :with=>content)
    else
      page.execute_script %{ace.edit($('.ace_editor').get(0)).getSession().setValue('#{content}')}
    end
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

When /^(?:|I )enter "([^"]*)" into "([^"]*)"$/ do |value, field|
  selector = ".RIGHT-#{field.to_name.safe_key} input.card-content"
  find( selector ).set value
end

Given /^(.*) (is|am) watching "([^\"]+)"$/ do |user, verb, cardname|
  user = Card::Auth.current.name if user == "I"
  signed_in_as user do
    step "the card #{cardname}+#{user}+*follow contains \"[[*always]]\""
  end
end

Given /^(.*) (is|am) not watching "([^\"]+)"$/ do |user, verb, cardname|
  user = Card::Auth.current.name if user == "I"
  signed_in_as user do
    step "the card #{cardname}+#{user}+*follow contains \"[[*never]]\""
  end
end


When /I wait a sec/ do
  sleep 1
end

When /I wait (.+) seconds$/ do |period|
  sleep period.to_i
end


Then /what/ do
  save_and_open_page
end

Then /debug/ do
  if RUBY_VERSION =~ /^2/
    require 'pry'
    binding.pry
  else
    debugger
  end
  nil
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

def signed_in_as username
  sameuser = (username == "I" or Card::Auth.current.key == username.to_name.key)
  was_signed_in = Card::Auth.current_id if Card::Auth.signed_in?
  unless sameuser
    step "I am signed in as #{username}"
  end
  yield
  unless sameuser
    step( was_signed_in ? "I am signed in as #{Card[was_signed_in].name}" : 'I follow "Sign out"' )
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

When /^In (.*) I find link with class "(.*)" and click it$/ do |section, css_class|
  within scope_of(section) do
    find("a.#{css_class}").click
  end
end

Then /I submit$/ do
    click_button("Submit")
end

When /^I hover over the main menu$/ do
  page.execute_script "$('#main > .card-slot > .card-header > .card-menu-link').trigger('mouseenter')"
end

When /^I pick (.*)$/ do |menu_item|
end

Then /the card (.*) should contain "([^\"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("main card content") do
    expect(page).to have_content(content)
  end
end

Then /the card (.*) should not contain "([^\"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("main card content") do
    expect(page).not_to have_content(content)
  end
end

Then /the card (.*) should point to "([^\"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("pointer card content") do
    expect(page).to have_content(content)
  end
end

Then /the card (.*) should not point to "([^\"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("pointer card content") do
    expect(page).not_to have_content(content)
  end
end



Then /^In (.*) I should see "([^\"]*)"$/ do |section, text|
  within scope_of(section) do
    if text.index('|')
      expect(text.split('|').any? {|t| have_content(t)}).to be
    else
      expect(page).to have_content(text)
    end
  end
end

Then /^In (.*) I should not see "([^\"]*)"$/ do |section, text|
  within scope_of(section) do
    expect(page).not_to have_content(text)
  end
end

Then /^In (.*) I should (not )?see a ([^\"]*) with class "([^\"]*)"$/ do |selection, neg, element, selector|
  # checks for existence of a element with a class in a selection context
  element = 'a' if element == 'link'
  within scope_of(selection) do
    page.send( ( neg ? :should_not : :should ), have_css( [ element, selector ] * '.' ) )
  end
end

Then /^In (.*) I should (not )?see a ([^\"]*) with content "([^\"]*)"$/ do |selection, neg, element, content|
  # checks for existence of a element with a class in a selection context
  element = 'a' if element == 'link'
  within scope_of(selection) do
    page.send( ( neg ? :should_not : :should ), have_css( element, :text=>content ) )
  end
end

Then /^the "([^"]*)" field should contain "([^"]*)"$/ do |field, value|
  expect(field_labeled(field).value).to match(/#{value}/)
end

Then /^"([^"]*)" should be selected for "([^"]*)"$/ do |value, field|
  expect(field_labeled(field).element.search(".//option[@selected = 'selected']").inner_html).to match(/#{value}/)
end

When /^I press enter to search$/ do
  find('#_keyword').native.send_keys(:return)
end

## variants of standard steps to handle """ style quoted args
Then /^I should see$/ do |text|
  expect(page).to have_content(text)
end

Then /^I should see "([^\"]*)" in color (.*)$/ do |text, css_class|
  page.has_css?(".diff-#{css_class}", text: text)
end

When /^I fill in "([^\"]*)" with$/ do |field, value|
  fill_in(field, :with => value)
end

