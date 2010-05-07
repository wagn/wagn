Feature: ImportExport
  In order to Facilitate making changes on multiple Wagns
  As a Wagneer
  I want to be able to dump changes and import them on other Wagns
  
  Background:
    Given I log in as Joe Admin
    And I create Cardtype card "Import"
    And I create Phrase card "Import+*type+*autoname" with content "Import-0000"
    And I go to url "/card/edit/Import/codename"
    And I fill in "codename" with "Import"
    And I press "Save"
    
  Scenario: capturing the export data
    When I create card "Exportable" with content "Boo"
    And I create card "Export" with content "{{Exportable|wdiff}}"
    And I go to card Export with none layout
    Then I should see 
      """
      --- 
      Exportable: 
        revisions: 
      """
    And I should see "::Joe Admin::+0:Boo"
    
  Scenario: importing a new card
    Given I go to new Import 
    And I fill in "card[content]" with 
      """
      NewlyImported: 
        revisions: 
        - 2010-05-06T11:47:34.745224-06:00::Joe User::+0:Boo
        type: Basic
      """
    When I go to card "NewlyImported"
    Then I should see "Boo"
  