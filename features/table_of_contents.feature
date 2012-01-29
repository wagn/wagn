Feature: Table of Contents
  In order to add a table of contents to a card
  As a Wagneer
  I want to be able to set a minimum header number
  
  Background:
    Given I log in as Joe Admin
    And I create Basic card "Two Header" with content "<h1>I'm a header</h1><h1>me too</h1>"
    And I create Basic card "Three Headers" with content "<h1>I'm a header</h1><h2>Me too</h2><h1>same here</h1>"
    
 Scenario: always on setting
   When I create Phrase card "Basic+*type+*table of contents" with content "1"
   When I go to card "Two Header"
   Then I should see "Table of Contents"
   
 Scenario: minimum setting
   When I create Phrase card "Basic+*type+*table of contents" with content "2"
   And I go to card "One Header"
   Then I should not see "Table of Contents"
   When I go to card "Three Headers"
   Then I should see "Table of Contents"
 
 Scenario: always off setting
   When I create Phrase card "Basic+*type+*table of contents" with content "0"
   And I go to card "One Header"
   Then I should not see "Table of Contents"
  
#  Scenario: header with unwanted html
#    When I create a Basic card "One Noisy Header" with content "<h2>I'm <b>sooo</b> NOSY</h2>"
#    And I go to card "One Noisy Header"
#    Then I should see "<b>sooo</b> NOSY" 
#    # in the content
#    And I should not see "sooo NOSY" 
#    #in the table
  
