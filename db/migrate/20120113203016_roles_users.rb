class RolesUsers < ActiveRecord::Migration
  def up
    User.as :wagbot do
      # Delete the old *roles template
      (c = Card['*assign_user_roles'])    && c.refresh && c.delete
      (c = Card['*role+*right+*content']) && c.refresh && c.delete
      (c=Card['*tasks+*right+*default'])  && c.refresh && c.delete
      Card.where("name like '%+*tasks'").each { |c| c.refresh && c.delete }
      Wagn::Cache.reset_global

      # Add rolename->*tasks pointers from roles.tasks
      Card.where(:extension_type => 'Role').each do |rolecard|
        tasks=rolecard.extension and tasks = tasks.tasks and tasks.split(',').each do |task|
            Card.fetch_or_new(Card.task_rule(task)) << rolecard
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
      c=Card['*account+*right+*create'] and c.delete
      Card.create! :name => "*account+*right+*create",
                   :type_id => Card::PointerID,
                   :content => "[[_left]]"

      # Add *account+*right+*update (administrate_users)
      c=Card['*account+*right+*update'] and c.delete
      Card.create! :name => "*account+*right+*update",
                   :type_id => Card::PointerID,
                   :content => "[[_left]]"

      # Add *roles+*right+*update   (edit_user_roles)
      Card.create! :name => "*roles+*right+*update",
                   :type_id => Card::PointerID,
                   :content => "[[_left]]"

      Card.create! :name => '*roles+*right+*default',
                   :type_id => Card::PointerID
    end
  end

  def down
    User.as :wagbot do
      Card.where("name like '%+*roles'").each { |c| c.delete }

      (c=Card['Role+*users+*type plus right+*content']) && c.delete
      (c=Card['*account+*right+*create'])               && c.delete
      (c=Card['*account+*right+*update'])               && c.delete
      (c=Card['*roles+*right+*update'])                 && c.delete
      (c=Card['*roles+*right+*default'])                 && c.delete
      (c=Card['*roles+*right+*update'])                 && c.delete
      (c=Card['*roles+*right'])                         && c.delete
      (c=Card['*roles'])                                && c.delete
    end
  end
end
