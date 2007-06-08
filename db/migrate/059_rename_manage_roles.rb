class RenameManageRoles < ActiveRecord::Migration
  def self.up
    Role.find(:all).each do |role|
      if role.tasks
		  role.tasks.gsub!('manage_roles','manage_permissions');
        role.save
		end
    end
  end

  def self.down
    Role.find(:all).each do |role|
      if role.tasks
		  role.tasks.gsub!('manage_permissions','manage_roles');
      	role.save
		end
    end
  end
end
