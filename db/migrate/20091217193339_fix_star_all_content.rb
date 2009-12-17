class FixStarAllContent < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Card['*all'].update_attributes :content=>"{}"
  end

  def self.down
  end
end
