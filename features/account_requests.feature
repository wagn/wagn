Feature: account requests
  In order to be able to manage new accounts strictly
  As a site manager
  I want to receive and approve/deny account requests

  Background:
    Given I sign up as "Wanna B" with email "wanna@wagn.org"
    And I log in as Joe Admin
    And I create card "User+*type+*structure" with content "{{+life story}}"

  Scenario: 
    When I go to card "AccountRequest"
    And In the main card content I click "Wanna B"
    When In the main card content I click "Invite Wanna B"
    Then I should not see "life story"
    When I press "Invite"
    Then I should see "Success"
    When I go to card "Wanna B"
    Then I should see "life story"
    
    #Then I should see "sent"

