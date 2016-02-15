@javascript
Feature: Conflict
  When I am editing a card and somebody else changes it at the same time I want to
  get a helpful message to solve the conflict.

  Background:
    Given I am signed in as Joe Admin
    And I create Phrase card "Duck Soup" with content "Laurel and Hardy"

  Scenario: Two edits on a card at the same time
    When I edit "Duck Soup" filling in "Stan Hardy"
    And I open a new window for Joe User
    And I edit "Duck Soup" setting content to "Oliver Laurel"

    # We still have Joe Admin's edit in the first window but we're globally signed in as Joe User.
    # We resign-in as Joe Admin in Joe User's window so that we submit Joe Admin's edit as Joe Admin
    And I am signed out
    And I wait a sec
    And I am signed in as Joe Admin
    And I close window
    And I submit
    Then I should see "Conflict!"
    And I should see "Joe User has also been making changes."
    And I should see "Oliver " in color green
    And I should see "Stan" in color red

  Scenario: Two edits on a card at the same time but with the same change
    When I edit "Duck Soup" filling in "Stan Laurel"
    And I open a new window for Joe User
    And I edit "Duck Soup" setting content to "Stan Laurel"
    And I am signed out
    And I wait a sec
    And I am signed in as Joe Admin
    And I close window
    And I submit
    Then I should see "Conflict!"
    #And I should see "No difference between your changes and Joe User's version."




