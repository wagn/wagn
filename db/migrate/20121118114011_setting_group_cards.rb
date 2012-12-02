class SettingGroupCards < ActiveRecord::Migration
  def up
    Account.as_bot do
      Card.create! :name=>"Permission", :codename=>:perms, :type_id=>Card::SettingID
      Card.create! :name=>"Look and Feel", :codename=>:look, :type_id=>Card::SettingID
      Card.create! :name=>"Communication", :codename=>:com, :type_id=>Card::SettingID
      Card.create! :name=>"Other", :codename=>:other, :type_id=>Card::SettingID
      Card.create! :name=>"Item Selection", :codename=>:pointer_group, :type_id=>Card::SettingID
    end
  end

  def down
    Account.as_bot do
      [:perms, :look, :com, :other, :pointer_group].each do |code|
        begin
        c=Card[code]
        c.codename=nil
        c.save!
        c.destroy
        rescue
        end
      end
    end
  end
end
