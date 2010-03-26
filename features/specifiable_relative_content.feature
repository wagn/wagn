Feature: Specifiable relative content
  In order to have an easy to use interface for creating cards
  As a Wagneer
  I want to be able to create links specifying content for plus cards of templated cards

  Scenario: User age
    Given I log in as Joe User
    And I go to url "/new/Book?_author=shakespeare&card[name]=btest"
    And I press "Submit"
    When I go to card btest+author
    Then I should see "shakespeare"
  
