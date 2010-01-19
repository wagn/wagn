Feature: Flexmail
  As a Wagneer
  I want to be able to set up email configs
  So that we can create emailing forms
  
  Background:
    Given I log in as Joe User
    And I create Cardtype card "Testimony"    
    And I create Pointer card "Testimony+*type+*send" with content "[[Testemailconfig]]"
    And I create card "Testimony+*tform" with content
      """
      {{+Name}} {{+Email}} {{+Testimony}} {{+recipients}}
      """

    And I create Email card "Testemailconfig"
      And I create Search card "Testemailconfig+*to" with content
        """
        {"referred_to_by":{"left":"_self","right":"recipients"}}
        """
      And I create Search card "Testemailconfig+*from" with content "{"left":"_self","right":"email"}"
      And I create Phrase card "Testemailconfig+*subject" with content "Subjectimus"
      And I create Phrase card "Testemailconfig+*bcc"
      And I create Basic card "Testemailconfig+*message" with content 
        """
        Pleistocles, 
        {{_self+Name|naked}} thinks you've got it all wrong.  He says:
        {{_self+*message}}
        
        buena,
        Thaddeus
        """

    And I create Phrase card "A+email" with content "tacitus@test.com"
    And I create Phrase card "B+email" with content "argumus@test.com"
    And I create Pointer card "List1" with content "[[A+email]]\n[[B+email]]"
    
    
  Scenario: Submitting a new Testimony
    When I create Testimony card "" with plusses:
      |Name|Email|Testimony|recipients|
      |Lee|lee@user.net|This is outrageous|List1|
    Then "tacitus@test.com" should receive 1 email
    And "argumus@test.com" should receive 1 email
    When "argumus@test.com" opens the email with subject "Subjectimus"
    And it should be from "lee@user.net"
    Then He should see "Pleistocles" in the email
    And He should see "Lee" in the email
    And He should see "This is outrageous" in the email
    