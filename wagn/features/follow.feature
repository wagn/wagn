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
    And I wait a sec
    Then I should not see "follow"

  Scenario: Watching a Card
    When I go to the homepage
    And I hover over the main menu
    And In the main card menu I click "follow"
    Then In the main card menu I should see "following|unfollow"
    # assumes focus still on that link.  otherwise "following"
    # selenium behavior not totally consistent here.
    And the card Joe User+*following should contain "Home"

  Scenario: Unwatching a Card
    Given Joe User is watching "Home"
    And I am on the homepage
    And I hover over the main menu
    And In the main card menu I find link with class "watch-toggle-off" and click it
    #note: the link name turns from "follwing" to "unfollow" on mouseover and because we don't control the mouse's position
    #      this test randomly fails if we use the link name
    Then In the main card menu I should see "follow"
    And the card Joe User+*following should not contain "Home"

  Scenario: Watching a Cardtype
    When I go to card User
    And I hover over the main menu
    And In the main card menu I should see "follow all"
    And In the main card menu I should not see "|"

  Scenario: A Card whose Cardtype is Watched
    Given Joe User is watching "User"
    And I go to card Joe User
    And I hover over the main menu
    Then In the main card menu I should see "(following)|unfollow"

#too long for menu
#
#  Scenario: Watching Cardtypes
#    Given Joe User is watching "Cardtype"
#    When I go to card User
#    Then In the main card footer I should see "watching Cardtype cards | watch User cards"



