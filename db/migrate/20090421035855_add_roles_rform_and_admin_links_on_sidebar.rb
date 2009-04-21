class AddRolesRformAndAdminLinksOnSidebar < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    
    if c=Card['*roles+*rform']
      c.extension_type='HardTemplate'
      c.save
    end
    if c=Card['Administrator links']
      c.permit(:read, Role[:admin])
      c.save
    end
    if c=Card['*sidebar']
      c.content = c.content+"<p>&nbsp;</p><p>{{Administrator links|open}}</p>"
      c.save
    end
    if c=Card['invitation email subject']
      c.destroy
    end
    if c=Card['invitation email body']
      c.destroy
    end
  end

  def self.down
  end
end
