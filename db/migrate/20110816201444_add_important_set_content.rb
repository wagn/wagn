class AddImportantSetContent < ActiveRecord::Migration
  def self.up
    User.as :wagbot do
      { '*all plus' => '{"left":{}}',
        '*star'     => '{"complete":"*"}',
        '*rstar'    => '{"right":{"complete":"*"}}',
      }.each do |key, value|
        c = Card.fetch key
        c.content = value
        c.save!
      end
    end
  end

  def self.down
  end
end
