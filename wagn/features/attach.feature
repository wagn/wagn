@javascript
Feature: Conflict
  I want to be able to upload files and images.

  Background:
    Given I am signed in as Joe Admin

  Scenario: Uploading a file
    When I go to new File
    And I upload a file
    And I wait a sec
    Then I should see "file.txt 9 Bytes"
    When I press "Delete"
    Then I should see "Add file..."
    When I upload a file
    And I wait a sec
    And I fill in "card_name" with "a test file"
    And I press "Submit"
    Then I should see "Download a test file"

  Scenario: Uploading a image
    When I go to new Image
    And I upload a image
    And I wait a sec
    Then I should see "image.png 169 KB"
    And I fill in "card_name" with "a test image"
    And I press "Submit"
    Then I should see a preview image of size "large"
