Feature: Notifications
  In order for Wagn to be a more effective communication platform
  Users should be able to track changes to Wagn cards from their email

  Scenario: Watching a Card
    Given Joe Admin is watching "Home"
    When Joe User edits "Home" setting content to "Boo!"
    Then Joe Admin should be notified that "Joe User edited \"Home\""

  Scenario: Watching a Type Card
    Given Joe Admin is watching "Phrase"
    When Joe User creates Phrase card "Foo" with content "bar"
    Then Joe Admin should be notified that "Joe User added \"Foo\""

  