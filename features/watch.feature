@javascript
Feature: Watch interface
  In order to make use of notifications
  As an Editor
  I want simple watch interface on cards

  Background:
    Given I am signed in as Joe User

  Scenario: Anonymous User should not see watch UI
    Given I follow "Sign out"
    When I go to the homepage
    And I hover over the main menu
    Then I should not see "follow"

  Scenario: Watching a Card
    When I go to the homepage
    And I hover over the main menu
    And In the main card menu I click "follow"
    Then In the main card menu I should see "unfollow"
    # assumes focus still on that link.  otherwise "following"
    # selenium behavior not totally consistent here.
    And the card Home+*watchers should contain "Joe User"

  Scenario: Unwatching a Card
    Given Joe User is watching "Home"
    And I am on the homepage
    And I hover over the main menu
    And In the main card menu I click "following"
    #note: turns to "unfollow on mouseover"
    Then In the main card menu I should see "follow"
    And the card Home+*watchers should not contain "Joe User"

  Scenario: Watching a Cardtype
    When I go to card User
    And I hover over the main menu
    And In the main card menu I should see "follow all"
    And In the main card menu I should not see "|"

  Scenario: A Card whose Cardtype is Watched
    Given Joe User is watching "User"
    And I go to card Joe User
    And I hover over the main menu
    Then In the main card menu I should see "(following)"

#too long for menu
#
#  Scenario: Watching Cardtypes
#    Given Joe User is watching "Cardtype"
#    When I go to card User
#    Then In the main card footer I should see "watching Cardtype cards | watch User cards"



