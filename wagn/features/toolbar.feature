@javascript
Feature: Toolbar
  In order to edit a card
  As a Wagneer
  I want to be able to use the toolbar

Background:
  Given I am signed in as Joe Admin
  And I go to card "Home"
  And I open the main card menu
  And I follow "edit"

Scenario: close toolbar
  Then In main card frame I should see a nav with class "toolbar"
  When In main card toolbar I find link with icon "remove" and click it
  Then In main card frame I should not see a nav with class "toolbar"

Scenario: pin and unpin toolbar
  When In main card toolbar I find button with icon "pushpin" and click it
  And I wait for ajax response
  And I go to card "Home"
  Then In main card frame I should see a nav with class "toolbar"
  And In main card toolbar I should see a button with class "toolbar-pin.active"
  When In main card toolbar I find button with icon "pushpin" and click it
  And I wait for ajax response
  And I go to card "Home"
  Then In main card frame I should not see a nav with class "toolbar"
