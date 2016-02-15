Feature: Structure Rules
  In order to have patterned content
  As a Wagneer
  I want to manage structure through rules

  Background:
    Given I am signed in as Joe Admin
    And I create Cardtype card "Movie"
    And I create card "Movie+*type+*structure" with content "{{+director}} {{+lead}} {{+color}}"
    And I create Phrase card "color+*right+*default" with content "true dat"

  Scenario: New structured card
    When I edit "Movie+*type+*structure"
    Then I should see "{{+lead}}"
    When I go to new Movie
    Then I should see "+director"
    And I should see "+lead"

  Scenario: Create and edit templated card
    When I create Movie card "Star Wars" with plusses:
      |director|lead|
      |George Lucas|Harrison Ford|
    And I go to card "Star Wars"
    Then In the main card content I should see "George Lucas"
    And In the main card content I should see "Harrison Ford"
    When I edit "Star Wars" with plusses:
      |director|lead|
      |G. Lucas|H. Ford|
    And I go to card "Star Wars"
    Then In the main card content I should see "G. Lucas"
    And In the main card content I should see "H. Ford"
    And In the main card content I should see "true dat"

  Scenario: Default on a ranking set
    Given I create card "Home Movie+*right+*default" with content "Watch this"
    When I go to new Movie card named "Lew+Home Movie"
    Then I should see "Watch this"



