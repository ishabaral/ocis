@api
Feature: MOVE file/folder

  Background:
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | Alice    |
      | Brian    |
    And user "Alice" has uploaded file with content "some data" to "/textfile0.txt"
    And user "Alice" has created folder "/PARENT"
    And user "Alice" has created folder "/FOLDER"
    And user "Alice" has uploaded file with content "some data" to "/PARENT/parent.txt"

  @smokeTest @skipOnBruteForceProtection @issue-brute_force_protection-112
  Scenario: send MOVE requests to webDav endpoints as normal user with wrong password
    When user "Alice" requests these endpoints with "MOVE" using password "invalid" about user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @smokeTest @skipOnBruteForceProtection @issue-brute_force_protection-112 @skipOnOcV10 @personalSpace
  Scenario: send MOVE requests to webDav endpoints as normal user with wrong password using the spaces WebDAV API
    When user "Alice" requests these endpoints with "MOVE" using password "invalid" about user "Alice"
      | endpoint                                           |
      | /remote.php/dav/spaces/%spaceid%/textfile0.txt     |
      | /remote.php/dav/spaces/%spaceid%/PARENT            |
      | /remote.php/dav/spaces/%spaceid%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @smokeTest @skipOnBruteForceProtection @issue-brute_force_protection-112
  Scenario: send MOVE requests to webDav endpoints as normal user with no password
    When user "Alice" requests these endpoints with "MOVE" using password "" about user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @smokeTest @skipOnBruteForceProtection @issue-brute_force_protection-112 @skipOnOcV10 @personalSpace
  Scenario: send MOVE requests to webDav endpoints as normal user with no password using the spaces WebDAV API
    When user "Alice" requests these endpoints with "MOVE" using password "" about user "Alice"
      | endpoint                                           |
      | /remote.php/dav/spaces/%spaceid%/textfile0.txt     |
      | /remote.php/dav/spaces/%spaceid%/PARENT            |
      | /remote.php/dav/spaces/%spaceid%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"


  Scenario: send MOVE requests to another user's webDav endpoints as normal user
    When user "Brian" requests these endpoints with "MOVE" about user "Alice"
      | endpoint                                           |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "403"

  @skipOnOcV10 @personalSpace
  Scenario: send MOVE requests to another user's webDav endpoints as normal user using the spaces WebDAV API
    When user "Brian" requests these endpoints with "MOVE" about user "Alice"
      | endpoint                                           |
      | /remote.php/dav/spaces/%spaceid%/textfile0.txt     |
      | /remote.php/dav/spaces/%spaceid%/PARENT            |
      | /remote.php/dav/spaces/%spaceid%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "403"


  Scenario: send MOVE requests to webDav endpoints using invalid username but correct password
    When user "usero" requests these endpoints with "MOVE" using the password of user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @skipOnOcV10 @personalSpace
  Scenario: send MOVE requests to webDav endpoints using invalid username but correct password using the spaces WebDAV API
    When user "usero" requests these endpoints with "MOVE" using the password of user "Alice"
      | endpoint                                           |
      | /remote.php/dav/spaces/%spaceid%/textfile0.txt     |
      | /remote.php/dav/spaces/%spaceid%/PARENT            |
      | /remote.php/dav/spaces/%spaceid%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"


  Scenario: send MOVE requests to webDav endpoints using valid password and username of different user
    When user "Brian" requests these endpoints with "MOVE" using the password of user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @skipOnOcV10 @personalSpace
  Scenario: send MOVE requests to webDav endpoints using valid password and username of different user using the spaces WebDAV API
    When user "Brian" requests these endpoints with "MOVE" using the password of user "Alice"
      | endpoint                                           |
      | /remote.php/dav/spaces/%spaceid%/textfile0.txt     |
      | /remote.php/dav/spaces/%spaceid%/PARENT            |
      | /remote.php/dav/spaces/%spaceid%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @smokeTest @skipOnBruteForceProtection @issue-brute_force_protection-112
  Scenario: send MOVE requests to webDav endpoints without any authentication
    When a user requests these endpoints with "MOVE" with no authentication about user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @smokeTest @skipOnBruteForceProtection @issue-brute_force_protection-112 @skipOnOcV10 @personalSpace
  Scenario: send MOVE requests to webDav endpoints without any authentication using the spaces WebDAV API
    When a user requests these endpoints with "MOVE" with no authentication about user "Alice"
      | endpoint                                           |
      | /remote.php/dav/spaces/%spaceid%/textfile0.txt     |
      | /remote.php/dav/spaces/%spaceid%/PARENT            |
      | /remote.php/dav/spaces/%spaceid%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @skipOnOcV10
  Scenario: send MOVE requests to webDav endpoints with body as normal user
    When user "Alice" requests these endpoints with "MOVE" including body "doesnotmatter" about user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/webdav/PARENT/parent.txt               |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "415"

  @skipOnOcV10 @personalSpace
  Scenario: send MOVE requests to webDav endpoints with body as normal user using the spaces WebDAV API
    When user "Alice" requests these endpoints with "MOVE" including body "doesnotmatter" about user "Alice"
      | endpoint                                           |
      | /remote.php/dav/spaces/%spaceid%/textfile0.txt     |
      | /remote.php/dav/spaces/%spaceid%/PARENT            |
      | /remote.php/dav/spaces/%spaceid%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "415"
