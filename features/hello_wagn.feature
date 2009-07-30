Feature: Seeing a card
  In order for the site to be remotely usable
  It should show me some text
  
  Scenario: Home page visit 
    When I go to the homepage
    Then I should see "Home"
    
  Scenario: Logged in home page visit
    Given I log in as Joe User
    When I go to the homepage
    Then I should see "My Card: Joe User" 
    
  Scenario: Create a Card
    Given I log in as Joe User
    When I create Phrase card "Buffalo" with content "Me and Me"
    And I go to card "Buffalo"
    Then In the main card header  I should see "Buffalo"
    And  In the main card header  I should see "Phrase"
    And  In the main card content I should see "Me and Me"
    