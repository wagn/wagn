Feature: Pointer Inputs
  In order to offer a more user friendly interface
  Users should be able to use different input methods for pointers

  Background:
    Given I log in as Joe User
    And I create Set card "right friends" with content "{"right":"friends"}"
    And I create Search card "right friends+*options" with content "{"type":"User"}"
    And I create Pointer card "friends+*rform"
   
  Scenario: Creating a card with select input
    Given I create Phrase card "right friends+*input" with content "select"
    When I go to card "Joe User+friends"
    And I select "Joe Camel" from "main_1-select"
    And I press "Create"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"   

  Scenario: Creating a templated card including a select input
    Given I create card "User+*tform" with content "{{+friends}}"
    And I create Phrase card "right friends+*input" with content "select"
    When I go to new User
    And I fill in "card_name" with "Jill"
    And I select "Joe Admin" from "main_1_1-select"
    And I press "Create"
    And I go to card "Jill"
    Then I should see "Joe Admin"
    
    ## FIXME:  the following assertions don't find the select field-- 
    #  apparently field_labelled(..) does a different search than
    #  select X from X.  
    # When I go to edit Joe User+friends
    # Then the "main_1-select" field should contain "Joe Camel"
    # And the "main_1-select" field should not contain "No Count"

  Scenario: Creating a card with multiselect input
    Given I create Phrase card "right friends+*input" with content "multiselect"
    When I go to card "Joe User+friends"
    And I select "Joe Camel" from "main_1-multiselect"
    And I press "Create"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel" 

  Scenario: Creating a templated card including a muliselect input
    Given I create card "User+*tform" with content "{{+friends}}"
    And I create Phrase card "right friends+*input" with content "multiselect"
    When I go to new User
    And I fill in "card_name" with "Jill"
    And I select "Joe Admin" from "main_1_1-multiselect"
    And I press "Create"
    And I go to card "Jill"
    And I should see "Joe Admin"
    
  Scenario: Creating a card with radio input
    Given I create Phrase card "right friends+*input" with content "radio"
    When I go to card "Joe User+friends"
    And I choose "main_1-radio-joe_camel"
    And I press "Create"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"

  Scenario: Creating a card with checkbox input
    Given I create Phrase card "right friends+*input" with content "checkbox"
    And I create a Phrase card "*all+*option text" with content "description"
    And I create a Basic card "Joe Camel+description" with content "boom yow yow"
    When I go to card "Joe User+friends"
    Then I should see "boom yow yow"
    And I check "main_1-checkbox-joe_camel"
    And I press "Create"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"


# should test:
# switching type before create from pointers
# correct default values for each input type selected / checked / filled in