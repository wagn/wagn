Feature: Pattern settings
  In order to control settings in an efficient way
  As a Wagneer
  I want to be able to control settings for patterns of cards
  
  Background:
    Given I log in as Joe User
    And I create card "*default+*new" with content "say something spicy"
    And I create Pattern card "plus color" with content "{"right": "color"}"

  Scenario: default setting and plus card override
    Given I create Phrase card "plus color+*new" with content "If colorblind, leave blank"
    When I go to new card named "Test"
    Then I should see "spicy"
    When I go to new card "Test+color"      
    Then I should see "colorblind"
  
  Scenario: rform Pattern
    Given I create Pattern card "*on right+*rform" with content "{"right": "_self"}"
    And I create Phrase card "cereal+*on right+*new" with content "I go poopoo for poco cuffs"
    When I go to new card named "Test+cereal"
    Then I should see "poopoo"

  Scenario: Solo Pattern
    Given I create Pattern card "*solo+*rform" with content "{"name": "_self"}"
    And I create Pointer card "cereal+*solo+*layout" with content "[[cereal layout]]" 
    And I create card "cereal layout" with content "My very own header"
    When I go to card "cereal"
    Then I should see "My very own"


  
