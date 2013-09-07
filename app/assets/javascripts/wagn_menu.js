wagn.menu_template = [
  { "text":"edit", "view":"edit", "if":"edit", "sub":
    [
      { "text":"content",       "view":"edit"                                                 },
      { "text":"name",          "view":"edit_name"                                            },
      { "text":"type: %{type}", "view":"edit_type"                                            },
      { "text":"structure", "related":{ "name":"structure", "view":"edit" }, "if":"structure" },
      { "link":"delete",                                                     "if":"delete"    }
    ]
  },  
  { "text":"view", "view":"home",  "sub":
    [
      { "text":"refresh",       "view":"home"                                  },
      { "text":"page",          "page":"self",                                 },
      { "text":"type: %{type}", "page":"type"                                  },
      { "text":"history",       "view":"history",             "if":"edit"      },
      { "text":"structure", "related":{ "name":"structure" }, "if":"structure" }
    ]
  },    
  { "text":"discuss", "related":"discussion", "if":"discuss"},
  { "text":"advanced", "view":"options", "sub":
    [
      { "text":"rules", "view":"options", "list":
        { "name": "related_sets",
          "template" : { "view":"options", "text":"text", "path_opts":"path_opts" } 
        } 
      },
      { "plain":"related", "list" : 
        { "name": "piecenames",
          "template": {"page":"item"},
          "append":[
            { "related":"children" },
            { "related":"mates" }
          ]
        }
      },
      { "related":"referred_to_by", "sub":[
          { "text":"all",        "related":"referred_to_by" },
          { "text":"links",      "related":"linked_to_by"   },
          { "text":"inclusions", "related":"included_by"    }
        ]
      },
      { "related":"refers_to", "sub":[
          { "text":"all",        "related":"refers_to"  },
          { "text":"links",      "related":"links_to"   },
          { "text":"inclusions", "related":"includes"   }
        ]
      },
      { "related":"editors", "if":"creator", "sub":[
          { "text":"all editors",          "related":"editors" },
          { "text":"creator: %{creator}",     "page":"creator" },
          { "text":"last editor: %{updater}", "page":"updater" }
        ]
      }
    ]
  },
  { "link":"watch", "if":"watch" },
  { "view":"account", "if":"account", "sub":
    [
      { "view":"account", "text":"details" },
      { "related":"created" },
      { "related":"edited" }
    ]
  }
  
]









