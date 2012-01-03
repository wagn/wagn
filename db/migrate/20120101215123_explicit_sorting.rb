load 'db/wagn_migration
_helper.rb'

class ExplicitSorting < ActiveRecord::Migration
  include WagnMigrationHelper

  def self.up
    cards = [

      [ "*attach+*right+*options", "Search", <<CARDCONTENT
{"type": "File",
 "sort": "update"
}
CARDCONTENT
      ],

      [ "*editing+*right+*content", "Search", <<CARDCONTENT
{"edited_by": "_self",
 "sort": "update"
}
CARDCONTENT
      ],

      [ "*editors+*right+*content", "Search", <<CARDCONTENT
{"editor_of": "_self",
 "sort": "name"
}
CARDCONTENT
      ],

      [ "*includers+*right+*content", "Search", <<CARDCONTENT
{"include":"_self",
 "sort": "name"
}
CARDCONTENT
      ],

      [ "*inclusions+*right+*content", "Search", <<CARDCONTENT
{"included_by":"_self",
 "sort": "name"
}
CARDCONTENT
      ],

      [ "*links+*right+*content", "Search", <<CARDCONTENT
{"linked_to_by":"_self",
 "sort": "name"
}
CARDCONTENT
      ],

      [ "*linkers+*right+*content", "Search", <<CARDCONTENT
{"link_to":"_self",
 "sort": "name"
}
CARDCONTENT
      ],

      [ "*plus cards+*right+*content", "Search", <<CARDCONTENT
{"part":"_self",
 "sort": "name"
}
CARDCONTENT
      ],

      [ "*plus parts+*right+*content", "Search", <<CARDCONTENT
{"plus":"_self",
 "sort": "name"
}
CARDCONTENT
      ],

      [ "*refers to+*right+*content", "Search", <<CARDCONTENT
{"referred_to_by":"_self",
 "sort": "name"
}
CARDCONTENT
      ],

      [ "*referred to by+*right+*content", "Search", <<CARDCONTENT
{"refer_to":"_self",
 "sort": "name"
}
CARDCONTENT
      ],

      [ "*roles+*right+*content", "Search", <<CARDCONTENT
{"member": "_self",
 "sort": "name"
}
CARDCONTENT
      ],

      [ "*watching+*right+*content", "Search", <<CARDCONTENT
/* fixit - once "type" accepts card defs:
{"or": 
 {"and": {"plus": ["*watcher", {"refer_to": "_self"} ], "not": {"type": "Cardtype"} } },
 {"type": {"plus": ["*watcher", {"refer_to": "_self"} ], "type": "Cardtype"} }
}
*/

{"plus": ["*watcher", {"refer_to": "_self"} ],
 "sort": "name"
}
CARDCONTENT
      ],

    ]
    cards.each do |name, typecode, content|
      create_or_update_pristine Card.fetch_or_new(name), typecode, content.chomp
    end
  end

  def self.down
  end

end
