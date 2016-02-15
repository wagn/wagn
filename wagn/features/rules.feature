Feature: Set-based Rles
  In order to control settings in an efficient way
  As a Wagneer
  I want to be able to control rules for sets of cards

  Background:
    Given I am signed in as Joe Admin
    And I create card "*all+*help" with content "say something spicy"

  Scenario: default setting and plus card override
    Given I create Phrase card "color+*right+*add help" with content "If colorblind, leave blank"
    And I am signed in as Joe User
    When I go to new card named "Test"
    Then I should see "spicy"
    When I go to new card "Test+color"
    Then I should see "colorblind"

  Scenario: *right Set
    Given I create Phrase card "cereal+*right+*add help" with content "I go poopoo for poco puffs"
    And I am signed in as Joe User
    When I go to new card named "Test+cereal"
    Then I should see "poopoo"

  Scenario: *type_plus_right Set
    Given I create Phrase card "User+cereal+*type plus right+*help" with content "your favorite"
    When I go to card  "Joe User+cereal"
    Then I should see "your favorite"
    When I create card "User+*type+*structure" with content "{{+cereal}}"
    And I am signed in as Joe User
    And I edit "Joe User"
    Then I should see "your favorite"
    When I go to new card "Joe Admin+cereal"
    Then I should see "your favorite"

  Scenario: Solo Set
    Given I create Pointer card "cereal+*self+*layout" with content "[[cereal layout]]"
    And I am signed in as Joe User
    And I create card "cereal layout" with content "My very own header"
    When I go to card "cereal"
    Then I should see "My very own"



