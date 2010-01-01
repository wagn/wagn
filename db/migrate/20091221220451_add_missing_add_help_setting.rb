class AddMissingAddHelpSetting < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    unless Card["*add help"]
      Card.create! :name=>"*add help", :type=>"Setting"
    end
  end

  def self.down
  end
end
