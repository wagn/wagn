class RenameAndTouchUpStarCards < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    names={
      '*cards included'     => '*inclusions',
      '*cards that include' => '*includers',
      '*cards linked from'  => '*linkers',
      '*cards linked to'    => '*links',
    }
    names.keys.each do |old|
      if c = Card[old]
        c.name = names[old]
        c.confirm_rename = true
        c.save
      end
    end
    
    %w{ *rform *tform }.each do |name|
      c = Card[name]
      c.permit(:comment, nil)
    end 
    
  end

  def self.down
  end
end
