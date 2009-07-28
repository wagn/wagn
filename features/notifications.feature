Feature: Notifications    
  Background: 
    Given I log in as Joe User
    
  Scenario: Anonymous User
    Given I log out
    When I go to the homepage
    Then I should not see "watch"
  
  Scenario: Logged in User 
    When I go to the homepage
    Then In the main card footer I should see "watch" 
                                 
  Scenario: Watching a Card
    When I go to the homepage
    And In the main card footer I click the watch link    
    And the page updates
    Then In the main card footer I should see "unwatch"
    And the card Home+*watchers should contain "Joe User"

  Scenario: Unwatching a Card
    Given the pointer Home+*watchers contains "[[Joe User]]" 
    And I am on the homepage  
    When In the main card footer I click the unwatch link
    And the page updates
    Then In the main card footer I should not see "unwatch" 
    And the card Home+*watchers should not contain "Joe User"
           
  Scenario: Watching a Cardtype
    When I go to card User
    Then In the main card footer I should see "watch User cards"

  Scenario: A Card whose Cardtype is Watched
    Given the pointer User+*watchers contains "[[Joe User]]"
    And I go to card Joe User
    Then In the main card footer I should see "watching User cards"
  
  Scenario: Watching Cardtypes
    Given the pointer Cardtype+*watchers contains "[[Joe User]]"
    When I go to card User
    Then In the main card footer I should see "watching Cardtype cards | watch User cards"
  
