class FindAndDestroyQueryCards < ActiveRecord::Migration
  def self.up
    User.as :admin
    Card::Query.find_all_by_trash(false).plot(:destroy_without_trash)
    Card['Query'].destroy_without_trash
  end

  def self.down
  end
end
