class RestoreThanksSettings < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    %w[ signup invite request ].each do |thanks_nub|
      c = Card["*#{thanks_nub}+*type+*thanks"]
      c.update_attributes! :name=> "*#{thanks_nub}+*thanks", :confirm_rename=>true, :update_referencers=>true
      
      Card["*#{thanks_nub}+*type"].destroy!
    end
  end

  def self.down
  end
end
