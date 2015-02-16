When /^I expand act (\d+)$/ do |index|
  all("a.arrow-right")[-index.to_i].click
end
