class ConvertStarSendToSetting < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    c = Card.find_or_create! :name => "*send", :type=>"Setting"
    if c and c.type!="Setting"
      c.type = "Setting"
      c.save!
    end
    Card.find_or_create! :name => "*send+*right+*default", :type=>'Pointer', :content => "[[_left+email config]]"
    Card.find_or_create!( :name => "email config+*right+*default", 
      :content => "{{+*to}}<br/>{{+*bcc}}<br/>{{+*from}}<br/>{{+*subject}}<br/>{{+*message}}"
    )
  end

  def self.down
  end
end
