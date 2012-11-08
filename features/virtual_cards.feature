Feature: Virtual Cards

  Scenario: Virtual Search
    Given I log in as Joe Admin
    And I create Search card "editors+*right+*content" with content
      """
      {"editor_of":"_self"}
      """
    And I log in as Joe User
    And I create card "Scratch" with content "that itch"
    Then the card "Scratch+editors" should contain "Joe User"
