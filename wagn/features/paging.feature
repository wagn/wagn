@javascript
Feature: paging
  In order to see limited items per page
  As an Viewer
  I want to have paging function

  Background:
    # create a structure card
    # create a search card 
    # create a card to list the search card with structure
    Given I am signed in as Joe Admin
    And I create Search card "basic card search" with content "{\"type\":\"basic\", \"limit\":2}"
    And I create HTML card "basic item structure" with content "{{_|name}}"
    And I create HTML card "list all basic cards" with content "{{basic card search||content;structure:basic item structure}}"

  Scenario: jump to pages should keep the item structure
    When I go to card "list all basic cards"
    And I click "2" within ".paging"    
    And I wait until ajax response done
    # And debug
    Then I should see css class ".STRUCTURE-basic_item_structure" within ".search-result-item"
    And I click "3" within ".paging"    
    And I wait until ajax response done
    Then I should see css class ".STRUCTURE-basic_item_structure" within ".search-result-item"
