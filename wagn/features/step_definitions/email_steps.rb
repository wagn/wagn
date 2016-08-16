# -*- encoding : utf-8 -*-
# rubocop:disable Lint/AmbiguousRegexpLiteral
# Commonly used email steps
#
# To add your own steps make a custom_email_steps.rb
# The provided methods are:
#
# last_email_address
# reset_mailer
# open_last_email
# visit_in_email
# unread_emails_for
# mailbox_for
# current_email
# open_email
# read_emails_for
# find_email
#
# General form for email scenarios are:
#   - clear the email queue (done automatically by email_spec)
#   - execute steps that sends an email
#   - check the user received an/no/[0-9] emails
#   - open the email
#   - inspect the email contents
#   - interact with the email (e.g. click links)
#
# The Cucumber steps below are setup in this order.

module EmailHelpers
  def current_email_address
    # Replace with your a way to find your current email. e.g session -> email
    # last_email_address will return the last email address used by email spec to find an email.
    # Note that last_email_address will be reset after each Scenario.
    last_email_address || "fixthis@wagn.org"
  end
end

World(EmailHelpers)

#
# Reset the e-mail queue within a scenario.
# This is done automatically before each scenario.
#

Given /^(?:a clear email queue|no emails have been sent)$/ do
  reset_mailer
end

#
# Check how many emails have been sent/received
#

Then /^(?:I|they|"([^"]*?)") should receive (an|no|\d+) emails?$/ do |address, amount|
  expect(unread_emails_for(address).size).to eq(parse_email_count(amount))
end

Then /^(?:I|they|"([^"]*?)") should have (an|no|\d+) emails?$/ do |address, amount|
  expect(mailbox_for(address).size).to eq(parse_email_count(amount))
end

Then /^(?:I|they|"([^"]*?)") should receive (an|no|\d+) emails? with subject "([^"]*?)"$/ do |address, amount, subject|
  #  address = address_for_user address
  expect(unread_emails_for(address).count { |m| m.subject =~ Regexp.new(subject) }).to eq(parse_email_count(amount))
end

Then /^(?:I|they|"([^"]*?)") should receive an email with the following body:$/ do |address, expected_body|
  open_email(address, with_text: expected_body)
end

#
# Accessing emails
#

# Opens the most recently received email
When /^(?:I|they|"([^"]*?)") opens? the email$/ do |address|
  open_email(address)
end

When /^(?:I|they|"([^"]*?)") opens? the email with subject "([^"]*?)"$/ do |address, subject|
  open_email(address, with_subject: subject)
end

When /^(?:I|they|"([^"]*?)") opens? the email with text "([^"]*?)"$/ do |address, text|
  open_email(address, with_text: text)
end

#
# Inspect the Email Contents
#

Then /^(?:I|they) should see "([^"]*?)" in the email subject$/ do |text|
  expect(current_email).to have_subject(text)
end

Then /^(?:I|they) should see \/([^"]*?)\/ in the email subject$/ do |text|
  expect(current_email).to have_subject(Regexp.new(text))
end

Then /^(?:I|they) should see \|(.*)\| in the email body$/ do |text|
  expect(current_email.text_part.body.raw_source).to include(text.to_s)
end

Then /^(?:I|they) should see "(.*)" in the email body$/ do |text|
  expect(current_email.text_part.body.raw_source).to include(text.to_s)
end

Then /^(?:I|they) should see \/([^\/]*?)\/ in the email body$/ do |text|
  expect(current_email.html_part.body).to match(Regexp.new(text))
end

Then /^(?:I|they) should see the email delivered from "([^"]*?)"$/ do |text|
  expect(current_email).to be_delivered_from(text)
end

Then /^(?:I|they) should see "([^\"]*)" in the email "([^"]*?)" header$/ do |text, name|
  expect(current_email).to have_header(name, text)
end

Then /^(?:I|they) should see \/([^\"]*)\/ in the email "([^"]*?)" header$/ do |text, name|
  expect(current_email).to have_header(name, Regexp.new(text))
end

#
# Inspect the Email Attachments
#

Then /^(?:I|they) should see (an|no|\d+) attachments? with the email$/ do |amount|
  expect(current_email_attachments.size).to eq(parse_email_count(amount))
end

Then /^there should be (an|no|\d+) attachments? named "([^"]*?)"$/ do |amount, filename|
  expect(current_email_attachments.count { |a| a.original_filename == filename }).to eq(parse_email_count(amount))
end

Then /^attachment (\d+) should be named "([^"]*?)"$/ do |index, filename|
  expect(current_email_attachments[(index.to_i - 1)].original_filename).to eq(filename)
end

Then /^there should be (an|no|\d+) attachments? of type "([^"]*?)"$/ do |amount, content_type|
  expect(current_email_attachments.count { |a| a.content_type == content_type }).to eq(parse_email_count(amount))
end

Then /^attachment (\d+) should be of type "([^"]*?)"$/ do |index, content_type|
  expect(current_email_attachments[(index.to_i - 1)].content_type).to eq(content_type)
end

Then /^all attachments should not be blank$/ do
  current_email_attachments.each do |attachment|
    expect(attachment.size).not_to eq(0)
  end
end

Then /^show me a list of email attachments$/ do
  EmailSpec::EmailViewer.save_and_open_email_attachments_list(current_email)
end

#
# Interact with Email Contents
#

When /^(?:I|they) follow "([^"]*?)" in the email$/ do |link|   # "<- stop textmate from treating the rest of the file as a string
  visit_in_email(link)
end

When /^(?:I|they) click the first link in the email$/ do
  click_first_link_in_email
end

#
# Debugging
# These only work with Rails and OSx ATM since EmailViewer uses Rails.root and OSx's 'open' command.
# Patches accepted. ;)
#

Then /^save and open current email$/ do
  EmailSpec::EmailViewer.save_and_open_email(current_email)
end

Then /^save and open all text emails$/ do
  EmailSpec::EmailViewer.save_and_open_all_text_emails
end

Then /^save and open all html emails$/ do
  EmailSpec::EmailViewer.save_and_open_all_html_emails
end

Then /^save and open all raw emails$/ do
  EmailSpec::EmailViewer.save_and_open_all_raw_emails
end

Then /^(.*) should be notified that "(.*)"$/ do |username, subject|
  Timeout.timeout(Capybara.default_wait_time) do
    sleep(0.5) while page.evaluate_script("jQuery.active") != 0
  end
  Delayed::Worker.new.work_off
  email = address_for_user username
  begin
    step %("#{email}" should receive 1 email)
  rescue RSpec::Expectations::ExpectationNotMetError => e
    raise RSpec::Expectations::ExpectationNotMetError, %(#{e.message}\n Found the following emails:\n\n #{all_emails * "\n\n~~~~~~~~\n\n"})
  end
  open_email(email, with_subject: /#{subject}/)
end

Then /^No notification should be sent$/ do
  Timeout.timeout(Capybara.default_wait_time) do
    sleep(0.5) while page.evaluate_script("jQuery.active") != 0
  end
  Delayed::Worker.new.work_off
  expect(all_emails).to be_empty
end

def address_for_user username
  card_with_acct = username == "I" ? Auth.current : Card[username]
  card_with_acct ? card_with_acct.account.email : username
end
