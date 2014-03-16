Feature: Notifications
  In order for Wagn to be a more effective communication platform
  Users should be able to track changes to Wagn cards from their email

  Scenario: Watching a Card
    Given Joe Admin is watching "Home"
    And I sign in as Joe Admin
    When Joe User edits "Home" setting content to "Boo"
    Then Joe Admin should be notified that "Joe User updated \"Home\""
# FIXME:need multiline matching
    #And He should see "was just edited by Joe User" in the email
    #And He should see "You received this email because you're watching Home" in the email
    When I follow "Unwatch" in the email
    Then the card Home+*watchers should not contain "Joe Admin"

  Scenario: Watching a Type Card
    Given Joe Admin is watching "Phrase"
    And I sign in as Joe Admin
    When Joe User creates Phrase card "Foo" with content "bar"
    Then Joe Admin should be notified that "Joe User created \"Foo\""
    # FIXME:need multiline matching
    #And He should see "was just added by Joe User" in the email
    #And He should see "You received this email because you're watching Phrase cards" in the email
    When I follow "Unwatch" in the email
    Then the card Phrase+*watchers should not contain "Joe Admin"

  Scenario: Watching a Card
    Given Joe User is watching "Home"
    When Joe Admin deletes "Home"
    Then Joe User should be notified that "Joe Admin deleted \"Home\""

