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
  { "text":"discuss", "related":{"name":"+discussion"}, "if":"discuss"},
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
            { "related":"children", "if":"creator" },
            { "related":"mates" }
          ]
        }
      },
      { "related":"referred to by", "if":"creator", "sub":[
          { "text":"all",        "related":"referred to by" },
          { "text":"links",      "related":"linked to by"   },
          { "text":"inclusions", "related":"included by"    }
        ]
      },
      { "related":"refers to", "if":"creator", "sub":[
          { "text":"all",        "related":"refers to"  },
          { "text":"links",      "related":"links to"   },
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
  { "link":"follow_menu", "if":"show_follow", "sub":[ 
      { "link":"follow_submenu" },
      { "text":"advanced", "related":"following"}
    ]
  },
  { "text":"account", "related":{"name":"+*account", "view":"edit"}, "if":"account", "sub":
    [
      { "text":"account", "related":{"name":"+*account", "view":"edit"}, "text":"details" },
      { "related":"roles"   },
      { "related":"created" },
      { "related":"edited"  },
      { "related":"follows" }
    ]
  }
  
];
