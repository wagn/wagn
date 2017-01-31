@javascript
Feature: Pointer Inputs
  In order to offer a more user friendly interface
  As a User
  I want to use different input methods for pointers

  Background:
    Given I am signed in as Joe Admin
    And I create Pointer card "friends+*right+*default"
    And I create Search card "friends+*right+*options" with content "{"type":"User"}"

  Scenario: Creating a card with select input
    Given I create Phrase card "friends+*right+*input" with content "select"
    When I go to card "Joe User+friends"
    And I select "Joe Camel" from "Content"
    And I press "Submit"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"

  Scenario: Creating a structured card including a select input
    Given I create Phrase card "User+*type+*structure" with content "{{+friends}}"
    And I create Phrase card "friends+*right+*input" with content "select"
    When I edit "Joe User"
    And I select "Joe Admin" from "+friends"
    And I press "Submit"
    And I go to card "Joe User"
    Then I should see "Joe Admin"

  Scenario: Creating a card with multiselect input
    Given I create Phrase card "friends+*right+*input" with content "multiselect"
    When I go to card "Joe User+friends"
    And I select "Joe Camel" from "Content"
    And I press "Submit"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"

  Scenario: Creating a templated card including a multiselect input
    Given I create Phrase card "User+*type+*structure" with content "{{+friends}}"
    And I create Phrase card "friends+*right+*input" with content "multiselect"
    When I edit "Joe User"
    And I select "Joe Admin" from "friends"
    And I press "Submit"
    And I go to card "Joe User"
    And I should see "Joe Admin"

  Scenario: Creating a card with radio input
    Given I create Phrase card "friends+*right+*input" with content "radio"
    When I go to card "Joe User+friends"
    And I choose "Joe Camel"
    And I press "Submit"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"

  Scenario: Creating a card with checkbox input
    Given I create Phrase card "friends+*right+*input" with content "checkbox"
    #And I create a Phrase card "*all+*option label" with content "description"
    And I create a Phrase card "Joe Admin+description" with content "boom yow yow"
    When I go to card "Joe User+friends"
    Then I should see "boom yow yow"
    And I check "Joe Camel"
    And I press "Submit"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"
    And I edit "Joe User+friends"
    And I uncheck "Joe Camel"
    And I press "Submit"
    And I go to card "Joe User+friends"
    Then I should not see "Joe Camel"

# can't get fill_in to work. don't know why -efm
#  Scenario: Creating a card with list input
#    Given I go to card "Joe User+friends"
#    Then I fill in "pointer_item" with "Joe Camel"
#    And I press "Submit"
#    When I go to card "Joe User"
#    Then I should see "Joe Camel"
#

# should test:
# switching type before create from pointers
# correct default values for each input type selected / checked / filled in
