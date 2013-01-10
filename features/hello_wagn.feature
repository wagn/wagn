Feature: Seeing a card
  In order for the site to be remotely usable
  It should show me some text

  Background:
    Given I log in as Joe User
    #test authentication separately

#  @javascript
  Scenario: Home page visit
    When I go to the homepage
    Then I should see "Home"
    And I should see "Joe User"
    And I should see "Sign out"
    Then In the main card header I should see a link with class "ui-icon-gear"
    Then In the main card header I click "close Home"
    Then In the main card header I should not see a link with class "ui-icon-gear"
    Then In the main card header I click "open Home"
    Then In the main card header I should see a link with class "ui-icon-gear"

  Scenario: Create a Card
    Given I log in as Joe User
    When I create Phrase card "Buffalo" with content "Me and Me"
#    And I go to card "Buffalo"
    Then In the main card header  I should see "Buffalo"
    And  In the main card header  I should see "Phrase"
    And  In the main card content I should see "Me and Me"

