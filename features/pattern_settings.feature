Feature: Pattern settings
  In order to control settings in an efficient way
  As a Wagneer
  I want to be able to control settings for patterns of cards
  
  Background:
    Given I log in as Joe User

  Scenario: default setting and plus card override
    Given I create Pattern card "plus color" with content 
    """
    {"right": "color"}
    """
    And I create card "*default+*new" with content "say something spicy"
    And I create Phrase card "plus color+*new" with content "If colorblind, leave blank"
    When I go to new card named "Test"
    Then I should see "spicy"
    When I go to new card "Test+color"      
    Then I should see "colorblind"
    
  Scenario: single setting 
    Given I create Pattern card "plus color" with content 
    """
    {"right": "color"}
    """
    And I create card "*default+*edit" with content "say something spicy"
    And I create card "Test+color+*edit" with content "I like maroon"
    ##FIXME -- this isn't how this should work, is it?
    When I go to url "/card/edit/Joe_User"
    Then I should see "spicy"
    When I go to url "/card/edit/Test+color" 
    Then I should see "maroon"
  
                
  
