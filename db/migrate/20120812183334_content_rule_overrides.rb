class ContentRuleOverrides < ActiveRecord::Migration
  def up
    Session.as_bot do
      Card.search( :right=>'*default', :left=>{:right=>'*self'} ).each do |override|
        override = override.refresh if override.frozen?
        override.name = "#{override.cardname.trunk_name}+*content"
        override.content = '_self'
        override.save!
      end
    end
  end

  def down
  end
end
