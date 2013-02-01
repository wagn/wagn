Feature: templates
  In order to create structures
  Users should be able to template

  Background:
    Given I log in as Joe User

  Scenario: New templated card
    When I go to new Book
    Then I should see "+author"
    And I should see "+illustrator"

  Scenario: Create and edit templated card
    When I create Book card "Ulysses" with plusses:
      |author|illustrator|
      |Joyce|Picasso|
    And I go to card "Ulysses"
    Then In the the main card content I should see "Joyce"
    And In the the main card content I should see "Picasso"
    When I edit "Ulysses" with plusses:
      |author|illustrator|
      |Tolstoy|Goya|
    And I go to card "Ulysses"
    Then In the the main card content I should see "Tolstoy"
    And In the the main card content I should see "Goya"




