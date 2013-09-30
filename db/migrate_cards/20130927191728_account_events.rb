# -*- encoding : utf-8 -*-

class AccountEvents < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      aa = Card.fetch "#{ Card[ :account_request ].name }+#{ Card[ :type ].name}+#{ Card[:accountable ].name}", :new=>{}
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

  def down
    contentedly do
      
    end
  end
end
