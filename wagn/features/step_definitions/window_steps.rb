# -*- encoding : utf-8 -*-
# rubocop:disable Lint/AmbiguousRegexpLiteral

When /^I open a new window for (.*)$/ do |account_name|
  str =
    <<END_TAG
  window.open("", "#{account_name}", "height=600,width=800");
END_TAG
  page.execute_script(str)
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
  accounted = Card[account_name]
  visit "/update/:signin?card[subcards][%2B*email][content]=#{accounted.account.email}&card[subcards][%2B*password][content]=joe_pass"
end

When /I switch to (.+) window$/ do |window|
  if window == "first"
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.first)
  elsif window == "last"
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
  end
end

When /^I close window$/ do
  page.execute_script("window.close();")
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
end
