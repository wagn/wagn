Feature: Notifications
  In order for Wagn to be a more effective communication platform
  Users should be able to track changes to Wagn cards from their email

  Scenario: Watching a Card
    Given Joe Admin is watching "All Eyes On Me+*self"
    When Joe User edits "All Eyes On Me" setting content to "Boo"
    Then Joe Admin should be notified that "Joe User updated \"All Eyes On Me\""
    And the card All Eyes On Me+*followers should point to "Joe Admin"
    And I should see "was just updated by Joe User" in the email body
    And I should see |You received this email because you're following "All Eyes On Me"| in the email body
    When I am signed in as Joe Admin
    And I follow "Unfollow" in the email
    Then the card All Eyes On Me+*followers should not point to "Joe Admin"

  Scenario: Watching a Type Card
    Given Joe Admin is watching "Phrase+*type"
    When Joe User creates Phrase card "Foo" with content "bar"
    Then Joe Admin should be notified that "Joe User created \"Foo\""
    And the card Phrase+*type+*followers should point to "Joe Admin"
    And I should see "was just created by Joe User" in the email body
    #FIXME these double quotes are ugly
    And I should see |You received this email because you're following "all "Phrases""| in the email body
    When I am signed in as Joe Admin
    And I follow "Unfollow" in the email
    Then the card Phrase+*type+*followers should not point to "Joe Admin"

  Scenario: Watching a Card
    Given Joe User is watching "Home+*self"
    When Joe Admin deletes "Home"
    Then Joe User should be notified that "Joe Admin deleted \"Home\""

