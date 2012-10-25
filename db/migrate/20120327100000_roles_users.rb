class RolesUsers < ActiveRecord::Migration
  class RolesUser < ActiveRecord::Base
  end
  class Role < ActiveRecord::Base
  end
  
  def up
    Session.as Card::WagnBotID do
      # Delete the old *roles cards
      (Card.search(:right=>'*roles', :return=>'name') + 
        ['*roles+*right', '*roles+*right+*content', '*roles+*right+*default', '*tasks']).each do |name|
          
        if c = Card[name]
          c = c.refresh
          c.destroy!
        end
      end
      Wagn::Cache.reset_global
      

      Card.create! :name => '*roles+*right+*default', :type_id => Card::PointerID

      # Add rolename->*tasks pointers from roles.tasks
      Card.where( :extension_type => 'Role', :trash => false ).each do |rolecard|
        if oldrole=Role.where(:id=>rolecard.extension_id).first
          tasks = oldrole.tasks and tasks.split(',').each do |task|
            # mapping old task names to rule cardnames to use
            cardname = case task.to_sym
              when :create_accounts    ;  "*account+*right+*create"
              when :administrate_users ;  "*account+*right+*update"
              when :assign_user_roles  ;  "*roles+*right+*update"
              else                     ;   next
              end
            #puts "tasks ? #{task.inspect}[#{rolecard.name}] >> #{c.inspect}"
            c = Card.fetch_or_new cardname
            c.add_item rolecard.name
            c.save
          end
        end
      end

      # Add username->*roles pointers from user_roles table
      Card.where( :extension_type => 'User', :trash => false ).each do |usercard|
        user = User.where(:card_id=>usercard.id).first
        next unless user
        roles = RolesUser.where(:user_id=>user.id).map do |role_user|
          rcard = Card.where(:extension_id=>role_user.role_id, :extension_type => 'Role').first
          (rcard and rcard.id != Card::AnonID) ? rcard.name : nil
        end.compact

        unless roles.empty?
          roles_name =  usercard.cardname.trait_name :roles
          Card.create! :name => roles_name, :content => "[[#{ roles.join "]]\n[[" }]]"
        end
      end
      
      execute "delete from sessions"
      # because old sessions have old account ids and no longer make sense.


    end
  end

  def down
    Session.as :wagn_bot do
      (Card.search(:right=>'*roles', :return=>'name') + 
        ['*roles+*right', '*roles+*right+*content', '*roles+*right+*default', '*tasks']).each do |name|
        if c = Card[name]
          c = c.refresh
          c.destroy
        end
      end
      Wagn::Cache.reset_global
    end
  end
end
