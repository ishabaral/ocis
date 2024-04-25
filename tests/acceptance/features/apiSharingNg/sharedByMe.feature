Feature: resources shared by user
  As a user
  I want to get resources shared by me
  So that I can know about what resources are shared with others

  https://owncloud.dev/libre-graph-api/#/me.drive/ListSharedByMe

  Background:
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | Alice    |
      | Brian    |


  Scenario: sharer lists the file share (Personal space)
    Given user "Alice" has uploaded file with content "hello world" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | Personal     |
      | sharee          | Brian        |
      | shareType       | user         |
      | permissionsRole | Viewer       |
    When user "Alice" lists the shares shared by her using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "textfile.txt" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name",
        "size"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "type": "string",
              "enum": ["personal"]
            },
            "path": {
              "type": "string",
              "enum": ["/"]
            },
            "name": {
              "type": "string",
              "enum": ["/"]
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": [
                  "user"
                ],
                "properties": {
                  "user": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "type": "string",
                        "enum": [
                          "Brian Murphy"
                        ]
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "type": "string",
          "enum": ["textfile.txt"]
        },
        "size": {
          "type": "number",
          "enum": [
            11
          ]
        }
      }
    }
    """


  Scenario: sharer lists the file share shared from inside a folder (Personal space)
    Given user "Alice" has created folder "FolderToShare"
    And user "Alice" has uploaded file with content "hello world" to "FolderToShare/textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | FolderToShare/textfile.txt |
      | space           | Personal                   |
      | sharee          | Brian                      |
      | shareType       | user                       |
      | permissionsRole | Viewer                     |
    When user "Alice" lists the shares shared by her using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "textfile.txt" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name",
        "size"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "type": "string",
              "enum": ["personal"]
            },
            "path": {
              "type": "string",
              "enum": ["/FolderToShare"]
            },
            "name": {
              "type": "string",
              "enum": ["FolderToShare"]
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": [
                  "user"
                ],
                "properties": {
                  "user": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "type": "string",
                        "enum": [
                          "Brian Murphy"
                        ]
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "type": "string",
          "enum": ["textfile.txt"]
        },
        "size": {
          "type": "number",
          "enum": [
            11
          ]
        }
      }
    }
    """


  Scenario: sharer lists the folder share (Personal space)
    Given user "Alice" has created folder "FolderToShare"
    And user "Alice" has sent the following share invitation:
      | resource        | FolderToShare |
      | space           | Personal      |
      | sharee          | Brian         |
      | shareType       | user          |
      | permissionsRole | Viewer        |
    When user "Alice" lists the shares shared by her using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "FolderToShare" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "type": "string",
              "enum": ["personal"]
            },
            "path": {
              "type": "string",
              "enum": ["/"]
            },
            "name": {
              "type": "string",
              "enum": ["/"]
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": [
                  "user"
                ],
                "properties": {
                  "user": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "type": "string",
                        "enum": [
                          "Brian Murphy"
                        ]
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "type": "string",
          "enum": ["FolderToShare"]
        }
      }
    }
    """


  Scenario: sharer lists the file and folder shares (Personal space)
    Given user "Alice" has created folder "FolderToShare"
    And user "Alice" has uploaded file with content "hello world" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | Personal     |
      | sharee          | Brian        |
      | shareType       | user         |
      | permissionsRole | Viewer       |
    And user "Alice" has sent the following share invitation:
      | resource        | FolderToShare |
      | space           | Personal      |
      | sharee          | Brian         |
      | shareType       | user          |
      | permissionsRole | Viewer        |
    When user "Alice" lists the shares shared by her using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "textfile.txt" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name",
        "size"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "type": "string",
              "enum": ["personal"]
            },
            "path": {
              "type": "string",
              "enum": ["/"]
            },
            "name": {
              "type": "string",
              "enum": ["/"]
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": [
                  "user"
                ],
                "properties": {
                  "user": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "type": "string",
                        "enum": [
                          "Brian Murphy"
                        ]
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "type": "string",
          "enum": ["textfile.txt"]
        },
        "size": {
          "type": "number",
          "enum": [
            11
          ]
        }
      }
    }
    """
    And the JSON data of the response should contain resource "FolderToShare" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "type": "string",
              "enum": ["personal"]
            },
            "path": {
              "type": "string",
              "enum": ["/"]
            },
            "name": {
              "type": "string",
              "enum": ["/"]
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": [
                  "user"
                ],
                "properties": {
                  "user": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "type": "string",
                        "enum": [
                          "Brian Murphy"
                        ]
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "type": "string",
          "enum": ["FolderToShare"]
        }
      }
    }
    """


  Scenario: sharer lists the file and folder shares shared to group (Personal space)
    Given group "grp1" has been created
    And user "Alice" has created folder "FolderToShare"
    And user "Alice" has uploaded file with content "hello world" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | Personal     |
      | sharee          | grp1         |
      | shareType       | group        |
      | permissionsRole | Viewer       |
    And user "Alice" has sent the following share invitation:
      | resource        | FolderToShare |
      | space           | Personal      |
      | sharee          | grp1          |
      | shareType       | group         |
      | permissionsRole | Viewer        |
    When user "Alice" lists the shares shared by her using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "textfile.txt" with the following data:
      """
      {
        "type": "object",
        "required": [
          "parentReference",
          "permissions",
          "name",
          "size"
        ],
        "properties": {
          "parentReference": {
            "type": "object",
            "required": [
              "driveId",
              "driveType",
              "path",
              "name",
              "id"
            ],
            "properties": {
              "driveId": {
                "type": "string",
                "pattern": "^%space_id_pattern%$"
              },
              "driveType": {
                "const": "personal"
              },
              "path": {
                "const": "/"
              },
              "name": {
                "const": "/"
              },
              "id": {
                "type": "string",
                "pattern": "^%file_id_pattern%$"
              }
            }
          },
          "permissions": {
            "type": "array",
            "minItems": 1,
            "maxItems": 1,
            "items": {
              "type": "object",
              "required": [
                "grantedToV2",
                "id",
                "roles"
              ],
              "properties": {
                "grantedToV2": {
                  "type": "object",
                  "required": ["group"],
                  "properties": {
                    "group": {
                      "type": "object",
                      "required": [
                        "displayName",
                        "id"
                      ],
                      "properties": {
                        "id": {
                          "type": "string",
                          "pattern": "^%group_id_pattern%$"
                        },
                        "displayName": {
                          "const": "grp1"
                        }
                      }
                    }
                  }
                },
                "id": {
                  "type": "string",
                  "pattern": "^%permissions_id_pattern%$"
                },
                "roles": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 1,
                  "items": {
                    "type": "string",
                    "pattern": "^%role_id_pattern%$"
                  }
                }
              }
            }
          },
          "name": {
            "const": "textfile.txt"
          }
        }
      }
      """
    And the JSON data of the response should contain resource "FolderToShare" with the following data:
      """
      {
        "type": "object",
        "required": [
          "parentReference",
          "permissions",
          "name"
        ],
        "properties": {
          "parentReference": {
            "type": "object",
            "required": [
              "driveId",
              "driveType",
              "path",
              "name",
              "id"
            ],
            "properties": {
              "driveId": {
                "type": "string",
                "pattern": "^%space_id_pattern%$"
              },
              "driveType": {
                "const": "personal"
              },
              "path": {
                "const": "/"
              },
              "name": {
                "const": "/"
              },
              "id": {
                "type": "string",
                "pattern": "^%file_id_pattern%$"
              }
            }
          },
          "permissions": {
            "type": "array",
            "minItems": 1,
            "maxItems": 1,
            "items": {
              "type": "object",
              "required": [
                "grantedToV2",
                "id",
                "roles"
              ],
              "properties": {
                "grantedToV2": {
                  "type": "object",
                  "required": ["group"],
                  "properties": {
                    "group": {
                      "type": "object",
                      "required": [
                        "displayName",
                        "id"
                      ],
                      "properties": {
                        "id": {
                          "type": "string",
                          "pattern": "^%user_id_pattern%$"
                        },
                        "displayName": {
                          "const": "grp1"
                        }
                      }
                    }
                  }
                },
                "id": {
                  "type": "string",
                  "pattern": "^%permissions_id_pattern%$"
                },
                "roles": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 1,
                  "items": {
                    "type": "string",
                    "pattern": "^%role_id_pattern%$"
                  }
                }
              }
            }
          },
          "name": {
            "const": "FolderToShare"
          }
        }
      }
      """


  Scenario: sharer lists the file share (Project space)
    Given using spaces DAV path
    And the administrator has assigned the role "Space Admin" to user "Alice" using the Graph API
    And user "Alice" has created a space "NewSpace" with the default quota using the Graph API
    And user "Alice" has uploaded a file inside space "NewSpace" with content "hello world" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | NewSpace     |
      | sharee          | Brian        |
      | shareType       | user         |
      | permissionsRole | Viewer       |
    When user "Alice" lists the shares shared by her using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "textfile.txt" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name",
        "size"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "type": "string",
              "enum": ["project"]
            },
            "path": {
              "type": "string",
              "enum": ["/"]
            },
            "name": {
              "type": "string",
              "enum": ["/"]
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": [
                  "user"
                ],
                "properties": {
                  "user": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "type": "string",
                        "enum": [
                          "Brian Murphy"
                        ]
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "type": "string",
          "enum": ["textfile.txt"]
        },
        "size": {
          "type": "number",
          "enum": [
            11
          ]
        }
      }
    }
    """


  Scenario: sharer lists the file share shared from inside a folder (Project space)
    Given using spaces DAV path
    And the administrator has assigned the role "Space Admin" to user "Alice" using the Graph API
    And user "Alice" has created a space "NewSpace" with the default quota using the Graph API
    And user "Alice" has created a folder "FolderToShare" in space "NewSpace"
    And user "Alice" has uploaded a file inside space "NewSpace" with content "hello world" to "FolderToShare/textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | FolderToShare/textfile.txt |
      | space           | NewSpace                   |
      | sharee          | Brian                      |
      | shareType       | user                       |
      | permissionsRole | Viewer                     |
    When user "Alice" lists the shares shared by her using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "textfile.txt" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name",
        "size"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "type": "string",
              "enum": ["project"]
            },
            "path": {
              "type": "string",
              "enum": ["/FolderToShare"]
            },
            "name": {
              "type": "string",
              "enum": ["FolderToShare"]
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": [
                  "user"
                ],
                "properties": {
                  "user": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "type": "string",
                        "enum": [
                          "Brian Murphy"
                        ]
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "type": "string",
          "enum": ["textfile.txt"]
        },
        "size": {
          "type": "number",
          "enum": [
            11
          ]
        }
      }
    }
    """


  Scenario: sharer lists the folder share (Project space)
    Given using spaces DAV path
    And the administrator has assigned the role "Space Admin" to user "Alice" using the Graph API
    And user "Alice" has created a space "NewSpace" with the default quota using the Graph API
    And user "Alice" has created a folder "FolderToShare" in space "NewSpace"
    And user "Alice" has sent the following share invitation:
      | resource        | FolderToShare |
      | space           | NewSpace      |
      | sharee          | Brian         |
      | shareType       | user          |
      | permissionsRole | Viewer        |
    When user "Alice" lists the shares shared by her using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "FolderToShare" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "type": "string",
              "enum": ["project"]
            },
            "path": {
              "type": "string",
              "enum": ["/"]
            },
            "name": {
              "type": "string",
              "enum": ["/"]
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
        "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": [
                  "user"
                ],
                "properties": {
                  "user": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "type": "string",
                        "enum": [
                          "Brian Murphy"
                        ]
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "type": "string",
          "enum": ["FolderToShare"]
        }
      }
    }
    """


  Scenario: sharer lists the file and folder shares (Project space)
    Given using spaces DAV path
    And the administrator has assigned the role "Space Admin" to user "Alice" using the Graph API
    And user "Alice" has created a space "NewSpace" with the default quota using the Graph API
    And user "Alice" has created a folder "FolderToShare" in space "NewSpace"
    And user "Alice" has uploaded a file inside space "NewSpace" with content "hello world" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | NewSpace     |
      | sharee          | Brian        |
      | shareType       | user         |
      | permissionsRole | Viewer       |
    And user "Alice" has sent the following share invitation:
      | resource        | FolderToShare |
      | space           | NewSpace      |
      | sharee          | Brian         |
      | shareType       | user          |
      | permissionsRole | Viewer        |
    When user "Alice" lists the shares shared by her using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "textfile.txt" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name",
        "size"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "type": "string",
              "enum": ["project"]
            },
            "path": {
              "type": "string",
              "enum": ["/"]
            },
            "name": {
              "type": "string",
              "enum": ["/"]
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": [
                  "user"
                ],
                "properties": {
                  "user": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "type": "string",
                        "enum": [
                          "Brian Murphy"
                        ]
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "type": "string",
          "enum": ["textfile.txt"]
        },
        "size": {
          "type": "number",
          "enum": [
            11
          ]
        }
      }
    }
    """
    And the JSON data of the response should contain resource "FolderToShare" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "type": "string",
              "enum": ["project"]
            },
            "path": {
              "type": "string",
              "enum": ["/"]
            },
            "name": {
              "type": "string",
              "enum": ["/"]
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": [
                  "user"
                ],
                "properties": {
                  "user": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "type": "string",
                        "enum": [
                          "Brian Murphy"
                        ]
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "type": "string",
          "enum": ["FolderToShare"]
        }
      }
    }
    """


  Scenario: sharer lists the file and folder shares shared to group (Project space)
    Given group "grp1" has been created
    And using spaces DAV path
    And the administrator has assigned the role "Space Admin" to user "Alice" using the Graph API
    And user "Alice" has created a space "new-space" with the default quota using the Graph API
    And user "Alice" has uploaded a file inside space "new-space" with content "some content" to "textfile.txt"
    And user "Alice" has created a folder "FolderToShare" in space "new-space"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | new-space    |
      | sharee          | grp1         |
      | shareType       | group        |
      | permissionsRole | Viewer       |
    And user "Alice" has sent the following share invitation:
      | resource        | FolderToShare |
      | space           | new-space     |
      | sharee          | grp1          |
      | shareType       | group         |
      | permissionsRole | Viewer        |
    When user "Alice" lists the shares shared by her using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "textfile.txt" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name",
        "size"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "const": "project"
            },
            "path": {
              "const": "/"
            },
            "name": {
              "const": "/"
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": ["group"],
                "properties": {
                  "group": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%group_id_pattern%$"
                      },
                      "displayName": {
                        "const": "grp1"
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "const": "textfile.txt"
        }
      }
    }
    """
    And the JSON data of the response should contain resource "FolderToShare" with the following data:
    """
    {
      "type": "object",
      "required": [
        "parentReference",
        "permissions",
        "name"
      ],
      "properties": {
        "parentReference": {
          "type": "object",
          "required": [
            "driveId",
            "driveType",
            "path",
            "name",
            "id"
          ],
          "properties": {
            "driveId": {
              "type": "string",
              "pattern": "^%space_id_pattern%$"
            },
            "driveType": {
              "const": "project"
            },
            "path": {
              "const": "/"
            },
            "name": {
              "const": "/"
            },
            "id": {
              "type": "string",
              "pattern": "^%file_id_pattern%$"
            }
          }
        },
        "permissions": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": {
            "type": "object",
            "required": [
              "grantedToV2",
              "id",
              "roles"
            ],
            "properties": {
              "grantedToV2": {
                "type": "object",
                "required": ["group"],
                "properties": {
                  "group": {
                    "type": "object",
                    "required": [
                      "displayName",
                      "id"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "pattern": "^%user_id_pattern%$"
                      },
                      "displayName": {
                        "const": "grp1"
                      }
                    }
                  }
                }
              },
              "id": {
                "type": "string",
                "pattern": "^%permissions_id_pattern%$"
              },
              "roles": {
                "type": "array",
                "minItems": 1,
                "maxItems": 1,
                "items": {
                  "type": "string",
                  "pattern": "^%role_id_pattern%$"
                }
              }
            }
          }
        },
        "name": {
          "const": "FolderToShare"
        }
      }
    }
    """

  @env-config
  Scenario: sharer lists the file share after sharee (user) is deleted (Personal space)
    Given the config "GRAPH_SPACES_USERS_CACHE_TTL" has been set to "1"
    And the administrator has assigned the role "Admin" to user "Alice" using the Graph API
    And user "Alice" has uploaded file with content "hello world" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | Personal     |
      | sharee          | Brian        |
      | shareType       | user         |
      | permissionsRole | Viewer       |
    And user "Brian" has been deleted
    When user "Alice" lists the shares shared by her after clearing user cache using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should match
    """
    {
      "type": "object",
      "required": [
        "value"
      ],
      "properties": {
        "value": {
          "type": "array",
          "minItems":0,
          "maxItems":0
        }
      }
    }
    """

  @env-config
  Scenario: sharer lists the file share after sharee (group) is deleted (Personal space)
    Given the config "GRAPH_SPACES_GROUPS_CACHE_TTL" has been set to "1"
    And group "grp1" has been created
    And the administrator has assigned the role "Admin" to user "Alice" using the Graph API
    And user "Alice" has uploaded file with content "hello world" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | Personal     |
      | sharee          | grp1         |
      | shareType       | group        |
      | permissionsRole | Viewer       |
    And group "grp1" has been deleted
    When user "Alice" lists the shares shared by her after clearing group cache using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should match
    """
    {
      "type": "object",
      "required": [
        "value"
      ],
      "properties": {
        "value": {
          "type": "array",
          "minItems":0,
          "maxItems":0
        }
      }
    }
    """

  @env-config
  Scenario: sharer lists the file share after sharee is disabled (Personal space)
    Given the config "GRAPH_SPACES_USERS_CACHE_TTL" has been set to "1"
    And the administrator has assigned the role "Admin" to user "Alice" using the Graph API
    And user "Alice" has uploaded file with content "hello world" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | Personal     |
      | sharee          | Brian        |
      | shareType       | user         |
      | permissionsRole | Viewer       |
    And the user "Admin" has disabled user "Brian"
    When user "Alice" lists the shares shared by her after clearing user cache using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "textfile.txt" with the following data:
      """
      {
        "type": "object",
        "required": [
          "parentReference",
          "permissions",
          "name"
        ],
        "properties": {
          "parentReference": {
            "type": "object",
            "required": [
              "driveId",
              "driveType",
              "path",
              "name",
              "id"
            ],
            "properties": {
              "driveType": {
                "const": "personal"
              }
            }
          },
          "permissions": {
            "type": "array",
            "minItems": 1,
            "maxItems": 1,
            "items": {
              "type": "object",
              "required": [
                "grantedToV2",
                "id",
                "roles"
              ],
              "properties": {
                "grantedToV2": {
                  "type": "object",
                  "required": ["user"],
                  "properties": {
                    "user": {
                      "type": "object",
                      "required": [
                        "displayName",
                        "id"
                      ],
                      "properties": {
                        "displayName": {
                          "const": "Brian Murphy"
                        }
                      }
                    }
                  }
                },
                "roles": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 1,
                  "items": {
                    "type": "string",
                    "pattern": "^%role_id_pattern%$"
                  }
                }
              }
            }
          },
          "name": {
            "type": "string",
            "const": "textfile.txt"
          }
        }
      }
      """

  @env-config
  Scenario: sharer lists the file share after sharee (user) is deleted (Project space)
    Given the config "GRAPH_SPACES_USERS_CACHE_TTL" has been set to "1"
    And using spaces DAV path
    And the administrator has assigned the role "Space Admin" to user "Alice" using the Graph API
    And user "Alice" has created a space "new-space" with the default quota using the Graph API
    And user "Alice" has uploaded a file inside space "new-space" with content "some content" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | new-space    |
      | sharee          | Brian        |
      | shareType       | user         |
      | permissionsRole | Viewer       |
    And user "Brian" has been deleted
    When user "Alice" lists the shares shared by her after clearing user cache using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should match
      """
      {
        "type": "object",
        "required": [
          "value"
        ],
        "properties": {
          "value": {
            "type": "array",
            "minItems":0,
            "maxItems":0
          }
        }
      }
      """

  @env-config
  Scenario: sharer lists the file share after sharee (group) is deleted (Project space)
    Given the config "GRAPH_SPACES_GROUPS_CACHE_TTL" has been set to "1"
    And using spaces DAV path
    And group "grp1" has been created
    And the administrator has assigned the role "Space Admin" to user "Alice" using the Graph API
    And user "Alice" has created a space "new-space" with the default quota using the Graph API
    And user "Alice" has uploaded a file inside space "new-space" with content "some content" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | new-space    |
      | sharee          | grp1         |
      | shareType       | group        |
      | permissionsRole | Viewer       |
    And group "grp1" has been deleted
    When user "Alice" lists the shares shared by her after clearing group cache using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should match
      """
      {
        "type": "object",
        "required": [
          "value"
        ],
        "properties": {
          "value": {
            "type": "array",
            "minItems":0,
            "maxItems":0
          }
        }
      }
      """

  @env-config
  Scenario: sharer lists the file share after sharee is disabled (Project space)
    Given the config "GRAPH_SPACES_USERS_CACHE_TTL" has been set to "1"
    And using spaces DAV path
    And the administrator has assigned the role "Space Admin" to user "Alice" using the Graph API
    And user "Alice" has created a space "new-space" with the default quota using the Graph API
    And user "Alice" has uploaded a file inside space "new-space" with content "some content" to "textfile.txt"
    And user "Alice" has sent the following share invitation:
      | resource        | textfile.txt |
      | space           | new-space    |
      | sharee          | Brian        |
      | shareType       | user         |
      | permissionsRole | Viewer       |
    And the user "Admin" has disabled user "Brian"
    When user "Alice" lists the shares shared by her after clearing user cache using the Graph API
    Then the HTTP status code should be "200"
    And the JSON data of the response should contain resource "textfile.txt" with the following data:
      """
      {
        "type": "object",
        "required": [
          "parentReference",
          "permissions",
          "name"
        ],
        "properties": {
          "parentReference": {
            "type": "object",
            "required": [
              "driveId",
              "driveType",
              "path",
              "name",
              "id"
            ],
            "properties": {
              "driveType": {
                "const": "project"
              }
            }
          },
          "permissions": {
            "type": "array",
            "minItems": 1,
            "maxItems": 1,
            "items": {
              "type": "object",
              "required": [
                "grantedToV2",
                "id",
                "roles"
              ],
              "properties": {
                "grantedToV2": {
                  "type": "object",
                  "required": ["user"],
                  "properties": {
                    "user": {
                      "type": "object",
                      "required": [
                        "displayName",
                        "id"
                      ],
                      "properties": {
                        "displayName": {
                          "const": "Brian Murphy"
                        }
                      }
                    }
                  }
                },
                "roles": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 1,
                  "items": {
                    "type": "string",
                    "pattern": "^%role_id_pattern%$"
                  }
                }
              }
            }
          },
          "name": {
            "const": "textfile.txt"
          }
        }
      }
      """
