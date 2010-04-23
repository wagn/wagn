class RemoveRformTformRelatedCruft < ActiveRecord::Migration
  def self.up
    User.as(:wagbot)
    ["*rform","*tform","*type_subtab","Cardtype+*related",
      "related subtabs - cardtypes"
    ].each do |name|
      if c = Card[name]
        c.destroy
      end
    end
  end

  def self.down
  end
end
