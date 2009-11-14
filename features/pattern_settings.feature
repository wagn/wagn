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
    Then what
    Then I should see "colorblind"
  
                
  
