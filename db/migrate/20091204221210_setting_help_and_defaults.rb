class SettingHelpAndDefaults < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    ['*table of contents+*rform','*all+*table of contents'].each do |cardname|
      if c = Card.find_or_create(:name=>cardname)
        c.update_attributes( :type=>'Number', :content=>'4')
      end
    end
    Card.find_or_create(:name=>'*layout+*rform', :type=>'Pointer')
 
    {'*table of contents'=>'Autogenerate table of contents when card has at least this many headers ("0" means never).',
     '*layout'=>'Enter the card with the layout you want to apply to this [[set]].'
     }.each do |setting, help|
 
      card = Card.find_or_create :name=>"#{setting}+*edit", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content = help
        card.permit('edit',Role[:admin])
        card.permit('delete',Role[:admin])
        card.save!
      end
    end
  end

  def self.down
  end
end
