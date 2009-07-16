Feature: Recent Changes
  Scenario: Visiting Recent Changes
    Given I am on the homepage
    When I follow "Recent"
    Then I should see "Recently Changed Cards"
    And I should see "AdminNow"
    And I should see "Wagn Bot"
    