Feature: Content Settings
  In order to have patterned content
  As a Wagneer
  I want to manage content settings

  Background:
    Given I log in as Joe Admin
    And I create Cardtype card "Movie"
    And I create card "Movie+*type+*content" with content "{{+director}} {{+lead}} {{+color}}"
    And I create Phrase card "color+*right+*default" with content "true dat"

  Scenario: New card with templated content
    When I edit "Movie+*type+*content"
    And I should see "{{+lead}}"
    When I go to new Movie
    Then I should see "+director"
    And I should see "+lead"
    #And I should see "[~plus~lead]"

  Scenario: Create and edit templated card
    When I create Movie card "Star Wars" with plusses:
      |director|lead|
      |George Lucas|Harrison Ford|
    And I go to card "Star Wars"
    Then In the the main card content I should see "George Lucas"
    And In the the main card content I should see "Harrison Ford"
    When I edit "Star Wars" with plusses:
      |director|lead|
      |G. Lucas|H. Ford|
    And I go to card "Star Wars"
    Then In the the main card content I should see "G. Lucas"
    And In the the main card content I should see "H. Ford"
    And In the the main card content I should see "true dat"

  Scenario: Default on a ranking set
    Given I create card "Home Movie+*right+*default" with content "Watch this"
    When I go to new Movie card named "Lew+Home Movie"
    Then I should see "Watch this"






