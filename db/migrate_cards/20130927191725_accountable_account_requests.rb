# -*- encoding : utf-8 -*-

class AccountableAccountRequests < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      c = Card.fetch "#{ Card[ :account_request ].name }+#{ Card[ :type ].name}+#{ Card[:accountable ].name}", :new=>{}
      c.content = "1"
      c.save!    
    end
  end

  def down
    contentedly do
      
    end
  end
end
