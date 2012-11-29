class ContentRuleOverrides < ActiveRecord::Migration
  def up
    Account.as_bot do
      Card.search( :right=>'*default', :left=>{:right=>'*self'} ).each do |override|
        next if Card.exists? "#{override.cardname.trunk_name}+*content"
        override = override.refresh if override.frozen?
        override.name = "#{override.cardname.trunk_name}+*content"
        override.type = 'Basic'
        override.save!
        override = override.refresh
        override.content = '_self'
        override.save!
      end
    end
  end
  
  def down
  end
end
