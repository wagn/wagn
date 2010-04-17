class ContentSettings < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    c = Card.find_or_create! :name=>"*content", :type=>"Setting"
    if c and c.type!="Setting"
      c.type = "Setting"
      c.save!
    end
    
    c = Card.find_or_create! :name=>"*default", :type=>"Setting"
    if c and c.type!="Setting"
      c.type = "Setting"
      c.save!
    end
    
    Card.search( :right=>"*tform" ).each do |tform|
      begin
        typename = tform.name.trunk_name
        tform.update_attributes 
          :name => "#{typename}+*type+#{tform.extension_type=='HardTemplate' ? '*content' : '*default'}", 
          :confirm_rename => true, :update_referencers => true
        puts "migrated #{typename}+*tform"
      rescue Exception => e
        puts "Exception migrating #{typename}: #{e.message}"
      end
    end
    
    Wql.new( :right=>"*rform" ).run.each do |rform|
      begin
        leftname = rform.name.trunk_name
        rform.update_attributes :name => "#{leftname}+*right+#{tform.extension_type=='HardTemplate' ? '*content' : '*default'}",
          :confirm_rename => true, :update_referencers => true
        puts "migrated #{leftname}+*rform"
      rescue Exception => e
        puts "Exception migrating #{leftname}: #{e.message}"
      end
    end
  end

  def self.down
  end
end
