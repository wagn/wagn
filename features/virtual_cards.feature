Feature: Virtual Cards
  
  Scenario: Virtual Search
    Given I log in as Joe User
    And I create card "Scratch" with content "that itch"
    And I create Search card "editors+*right+*virtual" with content
      """
      {"edited_by":"_self"}
      """
    Then the card "Scratch+editors" should contain "Joe User"