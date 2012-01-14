class RolesUsers < ActiveRecord::Migration
  def up
    User.as :wagbot do
      # Delete the old *roles template
      (c = Card['*role+*right+*content']) && c.refresh && c.delete
      Wagn::Cache.reset_global
      STDERR << "Deleted #{c.inspect}\n"

      # Add rolename->*tasks pointers from roles.tasks
      Card.where(:extension_type => 'Role').each do |rolecard|
        tasks = rolecard.extension.tasks
        if tasks
          tasks = tasks.split(',').map(&:to_cardname).map(&:to_star)
          STDERR << "role #{rolecard.name} tasks #{tasks.inspect}\n"
          Card.create! :name    => rolecard.cardname.star_rule(:tasks),
                       :type_id => Card::PointerID,
                       :content => "[[#{tasks*']][['}]]"
        end
      end

      # Add username->*roles pointers from user_roles table
      Card.where(:extension_type=> 'User').each do |usercard|
        roles = usercard.extension.roles.map {|r| ((rcard=r.card).id!=Card::AnonID.to_s)? rcard.name : nil }.compact
        unless roles.empty?
          Card.create! :name    => usercard.cardname.star_rule(:roles),
                       :type_id => Card::PointerID,
                       :content => "[[#{roles*']][['}]]"
        end
      end

      # Add Role+*users+*type plus right+*content (edit_user_roles task)
      Card.create! :name => "Role+*users+*type plus right+*content",
                   :type_id => Card::PointerID,
                   :content => "{'type':'User';'refer_to':'_left'}"

      # Add *account+*right+*create (create_accounts task)
      Card.create! :name => "*account+*right+*create",
                   :type_id => Card::PointerID,
                   :content => "[[_left]]"

      # Add *account+*right+*update (administrate_users)
      Card.create! :name => "*account+*right+*update",
                   :type_id => Card::PointerID,
                   :content => "[[_left]]"

      # Add *roles+*right+*update   (edit_user_roles)
      Card.create! :name => "*roles+*right+*update",
                   :type_id => Card::PointerID,
                   :content => "[[_left]]"
    end
  end

  def down
    User.as :wagbot do
      Card.where("name like '%+*tasks'").each { |c| c.delete }
      Card.where("name like '%+*roles'").each { |c| c.delete }

      (c=Card['Role+*users+*type plus right+*content']) && c.delete
      (c=Card['*account+*right+*create'])               && c.delete
      (c=Card['*account+*right+*update'])               && c.delete
      (c=Card['*roles+*right+*update'])                 && c.delete
      (c=Card['*roles+*right'])                         && c.delete
      (c=Card['*roles'])                                && c.delete
    end
  end
end
