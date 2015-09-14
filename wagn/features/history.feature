@javascript
Feature: History
  As an editor
  I want to be able to browse through the history and save an old version as current.

  Background:
    Given I am signed in as Joe Admin
    Then the card First should not contain "chicken"

  Scenario: view history and rollback
    When I go to url "/First?view=history"
    Then In the main card content I should see a del with content "egg"

    When I expand act 2
    And In the main card content I click "Hide changes"
    Then In the main card content I should not see a del with content "egg"

    When In the main card content I click "Save as current"
    Then the card First should contain "chicken"
    Then I wait a sec


