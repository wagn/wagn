Feature: Forgot password
  In order to be able to recover lost account access
  As an authorized user
  I want to be able to reset my password

  Background:
#    Given I sign in as Joe Admin
#    And I create card "User+*type+*structure" with content "{{+life story}}"

  Scenario: Resetting password
    When I go to card *signin
    And I follow "RESET PASSWORD"
    And I enter "joe@user.com"
    And I click submit
    Then "joe@user.com" should receive an email with subject "verification link for My Wagn"
    When I open the email
    And I click the first link in the email
