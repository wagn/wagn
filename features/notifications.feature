Feature: Notifications
  Scenario: Anonymous User
    When I go to the homepage
    Then I should not see "watch"
  
  Scenario: Logged in User 
    Given I log in as Joe User
    When I go to the homepage
    Then In the main card footer I should see "watch" 
                                 
  Scenario: Watching a Card
    Given I log in as Joe User
    When I go to the homepage
    And In the main card footer I click the watch link    
    And the page updates
    Then In the main card footer I should see "unwatch"
    And the card Home+*watchers should contain "Joe User"

  Scenario: Unwatching a Card
    Given I log in as Joe User
    And the pointer Home+*watchers contains "[[Joe User]]" 
    And I am on the homepage  
    When In the main card footer I click the unwatch link
    And the page updates
    Then In the main card footer I should not see "unwatch"
    And the card Home+*watchers should not contain "Joe User"

