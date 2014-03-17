Feature: Signing up
  In order to be able to contribute content and be credited for my contributions
  As a content editor
  I want to signup for an account

  Background:
#    Given I sign in as Joe Admin
#    And I create card "User+*type+*structure" with content "{{+life story}}"

  Scenario: Signing up without approval
    Given Joe Admin creates Pointer card "User+*type+*create" with content "[[Anyone]]"
    And I sign up as "Wanna B" with email "wanna@wagn.org" and password "wanna_pass"
    Then I should see "Signup Success"
    And "wanna@wagn.org" should receive an email with subject "verification link for My Wagn"
    And I open the email
    And I click the first link in the email
    Then I should see "Wanna B"
    # need better indicator of success
  
  Scenario: Signing up with approval
    #When I go to card "AccountRequest"
    #And In the main card content I click "Wanna B"
    #When In the main card content I click "Invite Wanna B"
    #Then I should not see "life story"
    #When I press "Invite"
    #Then I should see "Success"
    #When I go to card "Wanna B"
    #Then I should see "life story"
    
    #Then I should see "sent"

