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