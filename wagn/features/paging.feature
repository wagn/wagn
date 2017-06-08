@javascript
Feature: paging
  In order to see limited items per page
  As an Viewer
  I want to have paging function

  Background:
    Given I am signed in as Joe Admin
    And I create Search card "basic card search" with content "{\"type\":\"basic\"}"

  Scenario: jump to pages should keep the item structure
    When I create HTML card "basic item structure" with content "{{_|name}}"
    And I create HTML card "list all basic cards" with content "{{basic card search||content;structure:basic item structure}}"
    And I go to card "list all basic cards"
    And I click "2" within ".paging"
    And I wait for ajax response
    Then I should see css class ".STRUCTURE-basic_item_structure" within ".search-result-item"
    And I click "3" within ".paging"
    And I wait for ajax response
    Then I should see css class ".STRUCTURE-basic_item_structure" within ".search-result-item"

  Scenario: jump to pages should keep the item view
    When I create HTML card "list basic types" with content "{{basic card search|open|closed}}"
    And I go to card "list basic types"
    And I click "2" within ".paging"
    And I wait for ajax response
    Then I should see css class ".closed-view" within ".search-result-item"
    And I click "3" within ".paging"
    And I wait for ajax response
    Then I should see css class ".TYPE-search.open-view"
    Then I should see css class ".closed-view" within ".search-result-item"



