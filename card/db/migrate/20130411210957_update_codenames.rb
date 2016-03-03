# -*- encoding : utf-8 -*-
class UpdateCodenames < ActiveRecord::Migration
  def up
    { content: :structure, edit_help: :help }.each do |oldname, newname|
      execute %(update cards set codename = "#{newname}" where codename = "#{oldname}";)
    end
  end

  def down
    { content: :structure, edit_help: :help }.each do |oldname, newname|
      execute %(update cards set codename = "#{oldname}" where codename = "#{newname}";)
    end
  end
end
