Feature: Virtual Cards
  
  Scenario: Virtual Search
    Given I log in as Joe Admin
    And I create card "Scratch" with content "that itch"
    And I create Search card "editors+*right+*content" with content
      """
      {"edited":"_self"}
      """
    Then the card "Scratch+editors" should contain "Joe User"
