Feature: Signing up
  In order to be able to contribute content and be credited for my contributions
  As a content editor
  I want to signup for an account

  Background:
    # By default Wagns are configured to require approval

  Scenario: Signing up (without approval) and then signing out and back in
    Given Joe Admin creates Pointer card "User+*type+*create" with content "[[Anyone]]"
    And I am signed out
    #This is the needed permission configuration to allow signups without approval

    When I go to the home page
    And I follow "Sign up"
    And I fill in "card_name" with "Wanna B"
    And I enter "wanna@wagn.org" into "*email"
    And I enter "wanna_pass" into "*password"
    And I press "Submit"
    Then I should see "Signup Success"
    And "wanna@wagn.org" should receive an email with subject "verification link for My Wagn"

    When I open the email
    And I click the first link in the email
    Then I should see "Wanna B"
    And "Wanna B" should be signed in

    When I go to the home page
    And I follow "Sign out"
    Then I should not see "Wanna B"

    When I follow "Sign in"
    And I enter "wanna@wagn.org" into "*email"
    And I enter "wanna_pass" into "*password"
    And I press "Sign in"
    Then I should see "Wanna B"
    And "Wanna B" should be signed in
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

