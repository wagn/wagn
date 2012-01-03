class NewLayoutType < ActiveRecord::Migration
  def up
    User.as :wagbot do
      Card.create! :name=>'Layout', :typecode=>'Cardtype'
      %w{ create update delete }.each do |setting|
        Card.create! :name=>"Layout+*type+*#{setting}", :typecode=>'Pointer', :content=>'[[Administrator]]'
      end
      Card.search( :referred_to_by=> {:right=>'*layout'} ).each do |card|
        card = card.refresh if card.frozen?
        card.typecode = 'Layout'
        card.save!
      end
    end
  end

  def down
    fail "no reversion built.  If this has run successfully and your intent is to revert prior migrations, try removing this file."
  end
end
