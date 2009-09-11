Feature: Pointer Inputs
  In order to offer a more user friendly interface
  Users should be able to use different input methods for pointers

  Background:
    Given I log in as Joe User
    And I create Search card "friends+*options" with content "{"type":"User"}"
    And I create Pointer card "friends+*rform"
   
  Scenario: Creating a card with dropdown input
    Given I create Phrase card "friends+*input" with content "select"
    When I go to card "Joe User+friends"
    And I select "Joe Camel" from "main_1-select"
    And I press "Create"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel" 
    ## FIXME:  the following assertions don't find the select field-- 
    #  apparently field_labelled(..) does a different search than
    #  select X from X.  
    # When I go to edit Joe User+friends
    # Then the "main_1-select" field should contain "Joe Camel"
    # And the "main_1-select" field should not contain "No Count"

  Scenario: Creating a card with multiselect input
    Given I create Phrase card "friends+*input" with content "multiselect"
    When I go to card "Joe User+friends"
    And I select "Joe Camel" from "main_1-multiselect"
    And I press "Create"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel" 
    
  Scenario: Creating a card with radio input
    Given I create Phrase card "friends+*input" with content "radio"
    When I go to card "Joe User+friends"
    And I choose "main_1-radio-joe_camel"
    And I press "Create"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"

  Scenario: Creating a card with checkbox input
    Given I create Phrase card "friends+*input" with content "checkbox"
    And I create a Phrase card "*option text" with content "description"
    And I create a Basic card "Joe Camel+description" with content "boom yow yow"
    When I go to card "Joe User+friends"
    Then I should see "boom yow yow"
    And I check "main_1-checkbox-joe_camel"
    And I press "Create"
    And I go to card "Joe User+friends"
    Then I should see "Joe Camel"

  Scenario: Creating a card with full input
    Given I create Search card "phone+*options" with content "{"type":"Phrase"}"
    And I create Pointer card "phone+*rform"
    And I create Phrase card "phone+*input" with content "full"
    And I create Phrase card "phone+*autoname" with content "1"
    When I go to card "Joe User+phone"
    And I fill in cards_joe_user_plus_phone_plus_1_content with "is you is"
    And I follow (the add new one link)
    And I fill in cards_joe_user_plus_phone_plus_1_content with "is you aint"
    And I press "Create"
    And I go to card "Joe User+phone"
    Then I should see "is you is"
    And I should see "is you aint"


    
# should test:
# switching type before create from pointers
# correct default values for each input type selected / checked / filled in