@javascript
Feature: Follow interface
  In order to make use of notifications
  As an Editor
  I want simple follow interface on cards

  Background:
    Given I am signed in as Joe User

  Scenario: Anonymous User should not see follow UI
    Given I follow "Sign out"
    When I go to the homepage
    And I open the main card menu
    Then I should not see "follow"

  Scenario: Following a Card
    Given Joe User is not watching "Home+*self"
    When I go to the homepage
    And I open the main card menu
    And In the main card menu I should not see "unfollow"
    And In the main card menu I click "follow"
    And I wait a sec
    And I close the modal window
    And I wait a sec
    And I open the main card menu
    Then In the main card menu I should see "unfollow"
    And the card Home+*self+Joe User+*follow should point to "always"

  Scenario: Unfollowing a Card
    Given Joe User is watching "Home+*self"
    And the card Home+*self+Joe User+*follow should point to "always"
    And I am on the homepage
    And I open the main card menu
    And In the main card menu I click "unfollow"
    And I wait a sec
    And I close the modal window
    And I wait a sec
    And I open the main card menu
    Then In the main card menu I should see "follow"
    And the card Home+*self+Joe User+*follow should point to "never"


  Scenario: Following a Cardtype
    When I go to card User
    And I open the main card menu
    Then In the main card menu I should see "follow"

  Scenario: A Card whose Cardtype is Followed
    Given Joe User is watching "User+*type"
    And I go to card Joe User
    And I open the main card menu
    Then In the main card menu I should see "(following)|unfollow"
    And I wait a sec

#too long for menu
#
#  Scenario: Watching Cardtypes
#    Given Joe User is watching "Cardtype"
#    When I go to card User
#    Then In the main card footer I should see "watching Cardtype cards | watch User cards"



