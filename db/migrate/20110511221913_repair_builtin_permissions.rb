class RepairBuiltinPermissions < ActiveRecord::Migration
  def self.builtin_list
    %w{ *alerts *foot *head *navbox *now *version *recent *search } << "*account links"
  end
  
  def self.up
    User.as(:wagbot) do
      builtin_list.each do |name|
        c = Card.fetch(name)
        c.permit(:read, Role[:anon])
        c.save
      end
    end
  end

  def self.down
  end
end
