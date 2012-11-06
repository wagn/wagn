Feature: Watch interface
  In order to more easily make use of notifications
  Users should access appropriate watch interface on cards

  Background:
    Given I log in as Joe User

  Scenario: Anonymous User should not see watch UI
    Given I log out
    When I go to the homepage
    Then I should not see "watch"

  Scenario: Watching a Card
    When I go to the homepage
    And In the main card footer I click "watch"
    Then In the main card footer I should see "unwatch"
    And the card Home+*watchers should contain "Joe User"

  Scenario: Unwatching a Card
    Given Joe User is watching "Home"
    And I am on the homepage
    When In the main card footer I click "unwatch"
    Then In the main card footer I should not see "unwatch"
    And the card Home+*watchers should not contain "Joe User"

  Scenario: Watching a Cardtype
    When I go to card User
    Then In the main card footer I should see "watch User cards"
    And In the main card footer I should not see "|"

  Scenario: A Card whose Cardtype is Watched
    Given Joe User is watching "User"
    And I go to card Joe User
    Then In the main card footer I should see "watching User cards"

  Scenario: Watching Cardtypes
    Given Joe User is watching "Cardtype"
    When I go to card User
    Then In the main card footer I should see "watching Cardtype cards | watch User cards"



