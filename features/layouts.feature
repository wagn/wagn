Feature: Layouts
  In order to have greater control over the look and feel of my website
  As a User
  I want custom html templates

  Scenario: I configure a simple layout
    Given I log in as Joe Admin
    And I create Html card "simple layout" with content "Simple Header {{_main}} Simple Footer"
    And I create card "Sample" with content "Sample Content" 
    And I create Pointer card "*layout" with content "[[simple layout]]"
    When I go to card "Sample"
    Then I should see "Simple Header"
    And I should see "Sample Content"
    
Scenario: title
  Given context
  When event
  Then outcome


