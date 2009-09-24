Feature: Google maps
  In order to provide spatial visualization of Wagn Cards
  As a User
  I want to see a list of cards placed on a map

  Background:
    Given I log in as Joe User
    And I create card "*geocode" with content "[[street address]]\n[[zip]]" 
    And I create card "street address" 
    And I create card "zip"
    And I create Cardtype card "House"
    And I create card "Ethan's House" with content "Welcome to Ft Collins!"
    And I create card "Lew's House" with content "Weclome to Chicago!"
    And I create card "Ethan's House+street address" with content "519 Peterson St"
    And I create card "Ethan's House+zip" with content "80524"    
    And I create card "Lew's House+street address" with content "4511 N Clarement"
    And I create card "Lew's House+zip" with content "60625"    
  
  Scenario: I look at the KML for a search
    When I go to card "House+*type_cards.kml"
    Then I should see "Welcome to Ft Collins!"
    And I should see "Welcome to Chicago!"
    

  @wip
  Scenario: I look at the map for a search
    Given I create Html card "FounderHouses" with content
    """
    <div id="FounderHouses_map"></div>
    <script type="text/javascript">
      jQuery("FounderHouses_map").googleMap("House+*type_cards.kml")
    </script>
    """
    When I got to "FounderHouses"
    Then I should see Markers on the map ...

  
  
      
    

  
  
  

