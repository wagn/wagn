Feature: Notifications
  In order for Wagn to be a more effective communication platform
  Users should be able to track changes to Wagn cards from their email

  Scenario: Watching a Card
    Given Joe Admin is watching "All Eyes On Me"
    And I am signed in as Joe Admin
    When Joe User edits "All Eyes On Me" setting content to "Boo"
    Then Joe Admin should be notified that "Joe User updated \"All Eyes On Me\""
    And the card Joe Admin+*following should contain "All Eyes On Me"
# FIXME:need multiline matching
    #And He should see "was just edited by Joe User" in the email
    #And He should see "You received this email because you're watching Home" in the email
    When I follow "Unfollow" in the email
    Then the card Joe Admin+*following should not contain "All Eyes On Me"

  Scenario: Watching a Type Card
    Given Joe Admin is watching "Phrase"
    And I am signed in as Joe Admin
    When Joe User creates Phrase card "Foo" with content "bar"
    Then Joe Admin should be notified that "Joe User created \"Foo\""
    And the card Joe Admin+*following should contain "Phrase"
    # FIXME:need multiline matching
    #And He should see "was just added by Joe User" in the email
    #And He should see "You received this email because you're watching Phrase cards" in the email
    When I follow "Unfollow" in the email
    Then the card Joe Admin+*following should not contain "Phrase"

  Scenario: Watching a Card
    Given Joe User is watching "Home"
    When Joe Admin deletes "Home"
    Then Joe User should be notified that "Joe Admin deleted \"Home\""

