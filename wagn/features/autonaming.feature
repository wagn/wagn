@javascript
Feature: autonaming
  In order to save effort from thinking up names
  As an Editor
  I want to be able to skip naming cards where names matter little

  Background:
    Given I am signed in as Joe Admin
    And I create Phrase card "Book+*type+*autoname" with content "Book_1"

  Scenario: Simple cardtype autoname
    When I go to new Book
    And I press "Submit"
    Then I should see "Book_1"
    And I go to new Book
    And I press "Submit"
    Then I should see "Book_2"
