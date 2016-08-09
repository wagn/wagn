# -*- encoding : utf-8 -*-
# rubocop:disable Lint/AmbiguousRegexpLiteral
When /^I expand act (\d+)$/ do |index|
  all("a.arrow-right")[-index.to_i].click
end
