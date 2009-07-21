Feature: Notifications
  Scenario: Anonymous User
    When I go to the homepage
    Then I should not see "watch"
  
  Scenario: Logged in User 
    Given I log in as Joe User
    When I go to the homepage
    Then In the main card footer I should see "watch" 
                                 
  Scenario: 
    Given I log in as Joe User
    When I go to the homepage
    And In the main card footer I click the watch link
    And I go to card Home+*watchers
    Then In the main card content I should see "Joe User"

