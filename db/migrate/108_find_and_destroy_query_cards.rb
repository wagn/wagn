class FindAndDestroyQueryCards < ActiveRecord::Migration
  def self.up 
    execute %q{ delete from recent changes }
    User.as :admin
    (Card::Query.find_all_by_trash(false)+[Card['Query']]).each do |x| 
      x.update_attributes :current_revision_id => nil
      x.revisions.plot(:destroy)
      x.destroy_without_trash
    end
  end

  def self.down
  end
end
