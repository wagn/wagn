@javascript
Feature: Layouts
  In order to have greater control over the look and feel of my website
  As a User
  I want custom html templates

  Background:
    Given I am signed in as Joe Admin
    And I create HTML card "simple layout" with content "Simple Header {{_main}} Simple Footer"
    And the card "*all+*layout" contains "[[simple layout]]"
    And I create Pointer card "User+*type+*layout" with content "[[user layout]]"
    And I create HTML card "user layout" with content "User Header {{_main}}"

  Scenario: I visit a Basic card with the simple layout
    When I go to card "*account links"
    Then I should see "Simple Header"
    And I should see "Joe Admin"

  Scenario: I visit a User card with the user layout
    When I go to card "Joe User"
    Then I should see "User Header"



