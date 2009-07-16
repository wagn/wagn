Feature: Notifications
  Scenario: Anonymous User
    When I go to the homepage
    Then I should not see "watch"
  
  Scenario: Logged in User 
    Given I log in as Joe User
    When I go to the homepage
    Then I should see "watch"


