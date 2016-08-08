# -*- encoding : utf-8 -*-

class AddMoreFollowingCards < Card::CoreMigration
  def up
    Card.create! name: "*follow", codename: "follow", type_code: :setting
    Card.create! name: "*follow+*right+*default", type_code: :pointer
    Card.create! name: "*follow+*right+*input", type_code: :pointer, content: "[[radio]]"
    Card.create! name: "*follow+*right+*help", content: "Get notified about changes", type_code: :phrase

    Card.create! name: "*followers", codename: "followers"
    Card.create! name: "*follow fields", codename: "follow_fields", type_code: :setting
    Card.create! name: "*follow fields+*right+*help", content: ""
    Card.create! name: "*follow fields+*right+*default", type_code: :pointer
    Card.create! name: "*all+*follow fields", content: "[[*include]]", type_code: :pointer

    # follow options
    Card.create! name: "*always", codename: "always"
    Card.create! name: "*never", codename: "never"

    # default follow rule
    Card.create! name: "*follow defaults", codename: "follow_defaults", type_code: :pointer
    Card.create! name: "*all+*all+*follow", type_code: :pointer, content: "[[*never]]"
  end
end
