class PatternizeHelpText < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    [ ['*new', '*add help'],
      ['*edit','*edit help'],
      ].each do |oldname, newname|
        
      c = Card[oldname]
      if c
        c.name = newname
        c.confirm_rename = true
        c.update_referencers = true
        c.save!
        c.type = 'Setting'
        c.save!
      end
      
      Card.search(:right=>"#{newname}").each do |c|
        if c.trunk.type == 'Cardtype'
          Card.create!(:name=>"#{c.trunk.name}+*type+#{newname}", :type=>c.cardtype.name, :content=>c.content)
        end
        
        c.name= c.name.trunk_name+"+*on right+#{newname}"
        c.confirm_rename = true
        c.update_referencers=true
        c.save!
      end
    end
  end

  def self.down
  end
end
