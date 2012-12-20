@javascript
Feature: Watch interface
  In order to more easily make use of notifications
  Users should access appropriate watch interface on cards

  Background:
    Given I log in as Joe User

  Scenario: Anonymous User should not see watch UI
    Given I log out
    When I go to the homepage
    And I hover over the main menu
    Then I should not see "follow"

  Scenario: Watching a Card
    When I go to the homepage
    And I hover over the main menu
    And In the main card header I click "follow"
    Then In the main card header I should see "following"
    And the card Home+*watchers should contain "Joe User"

  Scenario: Unwatching a Card
    Given Joe User is watching "Home"
    And I am on the homepage
    And I hover over the main menu
    And In the main card header I click "following"
    #note: turns to "unfollow on mouseover"
    Then In the main card header I should see "follow"
    And the card Home+*watchers should not contain "Joe User"

  Scenario: Watching a Cardtype
    When I go to card User
    And I hover over the main menu
    And In the main card header I should see "follow all"
    And In the main card header I should not see "|"

  Scenario: A Card whose Cardtype is Watched
    Given Joe User is watching "User"
    And I go to card Joe User
    And I hover over the main menu
    Then In the main card header I should see "(following)"

#too long for menu
#
#  Scenario: Watching Cardtypes
#    Given Joe User is watching "Cardtype"
#    When I go to card User
#    Then In the main card footer I should see "watching Cardtype cards | watch User cards"



