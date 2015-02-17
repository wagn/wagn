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
    And I hover over the main menu
    And I wait a sec
    Then I should not see "follow"

  Scenario: Following a Card
    When I go to the homepage
    And I hover over the main menu
    And In the main card menu I click "follow"
    Then In the main card menu I should see "unfollow"
    # assumes focus still on that link.  otherwise "following"
    # selenium behavior not totally consistent here.
    And the card Home+*self+Joe User+*follow should contain "always"

  Scenario: Unfollowing a Card
    Given Joe User is watching "Home+*self"
    And I am on the homepage
    And I hover over the main menu
    And In the main card menu I find link with class "watch-toggle-off" and click it
    #note: the link name turns from "follwing" to "unfollow" on mouseover and because we don't control the mouse's position
    #      this test randomly fails if we use the link name
    Then In the main card menu I should see "follow"
    And the card Home+*self+Joe User+*follow should not contain "always"

  Scenario: Following a Cardtype
    When I go to card User
    And I hover over the main menu
    And In the main card menu I should see "follow all"
    #And In the main card menu I should not see "|"

  Scenario: A Card whose Cardtype is Followed
    Given Joe User is watching "User+*type"
    And I go to card Joe User
    And I hover over the main menu
    Then In the main card menu I should see "(following)|unfollow"

#too long for menu
#
#  Scenario: Watching Cardtypes
#    Given Joe User is watching "Cardtype"
#    When I go to card User
#    Then In the main card footer I should see "watching Cardtype cards | watch User cards"



