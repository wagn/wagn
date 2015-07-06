@javascript
Feature: Rules Editor
  In order to edit rule for a card
  As a Wagneer
  I want to be able to edit rules for sets of cards
  Background:
    Given I am signed in as Joe Admin
    And I create Pointer card "test_pointer"

  Scenario: update options type from pointer to search
    Given I create Pointer card "test_pointer+*self+*options"
    When I go to edit rule "test_pointer"
    And I follow "Pointer"
    And I follow "options"
    And I wait a sec
    And I select "Search" from "card_type"
    And I wait a sec
    And I fill in "card_content" with "{"type":"User"}" 
    And I choose "card_name_test_pointerselfoptions"
    And I press "Submit"
    And I wait a sec
    Then I should see "Sample User"
    And I should see "Joe Admin"
    And I should see "Joe User"
    Then I should not see "JSON::ParserError"