class PatternizeSimpleSettings < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    
    { 'on right'       => '{"right":"_self"}',
      'is type'        => '{"type":"_self"}' ,
      'type and right' => '{"left":{"type":"_left"}, "right":"_right"}',
      'solo'           => '{"name":"_self"}'
    }.each do |key,val|
      Card.create! :name=>"*#{key}+*rform", :type=>'Pattern', :content=>val
    end
    
    #Singles
    Card.search(:right=>'*table of contents').each do |c|
      c.name= c.name.trunk_name+'+*solo+*table of contents'
      c.confirm_rename=true
      c.update_referencers=true
      c.content= (c.content=='off' ? '0' : '1')
      c.save!
    end
    
    #Tags
    ['input', 'options', 'option label'].each do |name|
      Card.search(:right=>"*#{name}").each do |c|
        c.name= c.name.trunk_name+"+*on right+*#{name}"
        c.confirm_rename = true
        c.update_referencers=true
        c.save!
      end
    end
    
    #Types
    ['autoname', 'thanks', 'captcha'].each do |name|
      Card.search(:right=>"*#{name}").each do |c|
        c.name= c.name.trunk_name+"+*is type+*#{name}"
        c.confirm_rename = true
        c.update_referencers=true
        c.save!
      end
    end
    
    #Defaults
    ['layout', 'captcha', 'option label'].each do |name|
      c = Card["*#{name}"]
      next if !c
      Card.create!(:name=>"*all+*#{name}", :type=>c.type, :content=>c.content)
      c.content=''
      c.save!
    end
    
    #Knobs  -- Later migrated to "Setting"
    Card.create! :name=>'Knob', :type=>'Cardtype'
    ['autoname', 'thanks', 'captcha', 'layout', 'table of contents', 'input', 'options', 'option label'].each do |name|
      c = Card["*#{name}"] || Card.new( :name => "*#{name}" )
      c.type = 'Knob'
      c.save!
    end
    
  end

  def self.down
  end
end
