# -*- encoding : utf-8 -*-

class AccountEvents < Card::CoreMigration
  def up
    aa = Card.fetch "#{ Card[ :signup ].name }+#{ Card[ :type ].name}+#{ Card[:accountable ].name}", :new=>{}
    aa.content = "1"
    aa.save!
    
    role_right = "#{ Card[ :roles ].name }+#{ Card[ :right ].name }"
    
    r_options = Card.fetch "#{ role_right }+#{ Card[ :options ].name }", :new=>{}
    r_options.type_id = Card::SearchTypeID
    r_options.content = %({"type":"role", "not":{"codename":["in","anyone","anyone_signed_in"]}})
    r_options.save!
    
    r_input = Card.fetch "#{ role_right }+#{ Card[ :input ].name }", :new=>{}
    r_input.content = '[[checkbox]]'
    r_input.save!
  end

end
