class RolesUsers < ActiveRecord::Migration
  class RolesUser < ActiveRecord::Base
  end
  
  def up
    Card.as Card::WagbotID do
      # Delete the old *roles template
      (c = Card['*assign_user_roles'] and c=c.refresh) && c.delete
      (c = Card['*role+*right+*content'] and c=c.refresh) && c.delete
      (c = Card['*role+*right+*default'] and c=c.refresh) && c.delete
      (c = Card['*tasks+*right+*default'] and c=c.refresh) && c.delete
      Card.search(:right=>"*tasks").map(&:refresh).each(&:delete)
      Wagn::Cache.reset_global

      # Add rolename->*tasks pointers from roles.tasks
      Card.where(:extension_type => 'Role').each do |rolecard|
        tasks=Role.where(:id=>rolecard.extension_id).first and
              tasks = tasks.tasks and tasks.split(',').each do |task|
            # mapping old task names to rule cardnames to use
            (c=Card.fetch_or_new( case task.to_sym
                when :create_accounts;    "*account+*right+*create"
                when :administrate_users; "*account+*right+*update"
                when :assign_user_roles;  "*roles+*right+*update"
              end )).add_item(rolecard.name)
            c.save
          end
      end

      # Add username->*roles pointers from user_roles table
      Card.where(:extension_type=> 'User').each do |usercard|
        uid = User.where(:card_id=>usercard.id).first.id
        roles = RolesUser.where(:user_id=>uid).map do |role_user|
            (rcard=Card.where(:id=>role_user.role_id).first and
               rcard.id != Card::AnonID) ?  rcard.name : nil
          end.compact

        unless roles.empty?
          Card.create! :name    => usercard.cardname.trait_name(:roles),
                       :type_id => Card::PointerID,
                       :content => "[[#{roles*']][['}]]"
        end
      end

      # Add Role+*users+*type plus right+*content (edit_user_roles task)
      Card.create! :name => "Role+*users+*type plus right+*content",
                   :type_id => Card::PointerID,
                   :content => "{'type':'User';'refer_to':'_left'}"

      # Add *account+*right+*create (create_accounts task)
      c=Card['*account+*right+*create'] and c << '_left' or
          Card.create(:name => "*account+*right+*create",
                      :type_id => Card::PointerID,
                      :content => "[[_left]]")

      # Add *account+*right+*update (administrate_users)
      Card['*account+*right+*update'] or
      Card.create!(:name => "*account+*right+*update",
                   :type_id => Card::PointerID,
                   :content => "[[_left]]")

      # Add *roles+*right+*update   (edit_user_roles)
      Card.create! :name => "*roles+*right+*update",
                   :type_id => Card::PointerID,
                   :content => "[[_left]]"

      Card.create! :name => '*roles+*right+*default',
                   :type_id => Card::PointerID
    end
  end

  def down
    Card.as :wagbot do
      Card.search(:right => '*roles').each &:delete

      (c=Card['Role+*users+*type plus right+*content']) && c.delete
      (c=Card['*account+*right+*create'])               && c.delete
      (c=Card['*account+*right+*update'])               && c.delete
      (c=Card['*roles+*right+*update'])                 && c.delete
      (c=Card['*roles+*right+*default'])                && c.delete
      (c=Card['*roles+*right+*update'])                 && c.delete
      (c=Card['*roles+*right'])                         && c.delete
      (c=Card['*roles'])                                && c.delete
    end
  end
end
