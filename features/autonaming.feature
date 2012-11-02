Feature: autonaming
  In order for users to have a more intuitive interface
  they should be able to skip naming cards in some cases

  Background:
    Given I log in as Joe Admin
    And I create Phrase card "Book+*type+*autoname" with content "Book_1"

  Scenario: Simple cardtype autoname
    When I go to new Book
    When I press "Submit"
    Then I should see "Book_1"
    #FIXME - does this really test that page got submitted?
    And I go to new Book
    And I press "Submit"
    Then I should see "Book_2"

#    And I go to new Book
#    Then I should see "Book 2"

