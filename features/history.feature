Feature: Setting up
  As an Editor
  I want to be able to rollback to an old version of a card.
  
  Background:
    
  Scenario: Editor restores old content of a card
    Given I am signed in as Joe Admin

    When I go to url "/First?view=history"
    Then I should see "chicken"
    
    When I follow ""
    Then I should see "Save as current"
    # And I hover over the main menu
    # And In the main card menu I click "view"
    # Then I should see "Welcome"
    #
    # When I fill in "card_name" with "The Newber"
    # And I enter "newb@wagn.org" into "*email"
    # And I enter "newb_pass" into "*password"
    # And I press "Set up"
    # Then I should see "The Newber"
    #
    # When I go to card "The Newber\+\*roles"
    # Then I should see "Administrator"
    #
    # When I follow "Sign out"
    # And I follow "Sign in"
    # And I enter "newb@wagn.org" into "*email"
    # And I enter "newb_pass" into "*password"
    # And I press "Sign in"
    # Then I should see "The Newber"
    #
    # And site stops simulating setup need
  
