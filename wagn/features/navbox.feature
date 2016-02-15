@javascript
Feature: Navbox
  As a Casual site user
  I want to be able search for site content

  Scenario: quick search
    Given I go to the homepage
    And I fill in "_keyword" with "Joe"
# possible to use placeholder?
    And I wait a sec    
    Then I should see "Joe Camel"
    And I should see "JoeNow"
    Then I press enter to search
#When I follow "search: Joe" 
# fixme: unable to click link so far...
    And I wait a sec
    Then I should see "Search results"
  