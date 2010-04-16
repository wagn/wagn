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
        tform.update_attributes :name => "#{typename}+*type+*default", 
          :confirm_rename => true, :update_referencers => true

        if tform.extension_type == 'HardTemplate'
          Card.create! :name => "#{typename}+*type+*content", :content => tform.content
        end
        puts "migrated #{typename}+*tform"
      rescue Exception => e
        puts "Exception migrating #{typename}: #{e.message}"
      end
    end
    
    Wql.new( :right=>"*rform" ).run.each do |rform|
      begin
        leftname = rform.name.trunk_name
        
        if rform.extension_type == 'HardTemplate'
          rform.update_attributes :name => "#{leftname}+*right+*content",
            :confirm_rename => true, :update_referencers => true
        else
          rform.update_attributes :name => "#{leftname}+*right+*default",
            :confirm_rename => true, :update_referencers => true
        end
      
        puts "migrated #{leftname}+*rform"
      rescue Exception => e
        puts "Exception migrationg #{leftname}: #{e.message}"
      end
    end
  end

  def self.down
  end
end
