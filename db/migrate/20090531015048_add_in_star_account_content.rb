class AddInStarAccountContent < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    
    c = Card['*account']
    if c.current_revision.created_by.login == 'wagbot'
      c.content = 
        %{<p>[[/account/invite|Invite a new user]]</p>
          <p>&nbsp;</p>
          <p>By default, accounts other than [[Anonymous]] and [[Wagn Bot]] are associated with [[User]] cards. See the [[http://wagn.org/wagn/account|documentation on accounts]] to learn more.</p>
          <p>&nbsp;</p>
          <h1>Account Requests<br /></h1>
          <p>{{Account Request+*type cards}}</p>
          <p>&nbsp;</p>
          <p>{{Cards with accounts|titled}}</p>}
      c.save!
    end
  end

  def self.down
  end
end
