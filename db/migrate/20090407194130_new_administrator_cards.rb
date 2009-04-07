class NewAdministratorCards < ActiveRecord::Migration
  def self.up
    user = User[:wagbot]
    user.roles=[Role[:admin]]
    User.as :wagbot
    
    [ ['Cards with Accounts', 'Search', %{{"extension_type": "User"}}], 
      ['Accounts', 'Basic', %{<p>[[/account/invite|Invite a new user]]</p><p>&nbsp;</p><p>{{Cards with accounts|titled}}</p>}],
      ['Administrator links', 'Basic', %{<p>[[*account|Accounts]]</p><p>[[Roles]]</p><p>[[/admin/tasks|Global permissions]]</p>}]
    ].each do |card_def|
        
      name, type, content = card_def
      unless Card[name]
        Card.create!(:name=>name, :type=>type, :content=>content)
      end
    end
  end

  def self.down
  end
end
