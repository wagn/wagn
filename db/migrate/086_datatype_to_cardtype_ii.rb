class NCard < ActiveRecord::Base
  set_table_name 'cards'
  set_inheritance_column nil
  belongs_to :tag, :class_name=>'NTag', :foreign_key=>"old_tag_id"
  belongs_to :extension, :polymorphic=>true    

  def simple?() self.trunk_id.nil? end

  def before_destroy
    self.update_attribute('current_revision_id', nil)
  end
  
  def datatype_key 
    simple? ? tag.datatype_key : tag.plus_datatype_key
  end
end

class NTag < ActiveRecord::Base
  set_table_name 'tags'
  has_one :root_card, :class_name=>'NCard', :foreign_key=>"old_tag_id",:conditions => "trunk_id IS NULL"
  has_many :cards, :class_name=>'NCard', :foreign_key=>"old_tag_id", :conditions=>"trunk_id IS NOT NULL", :dependent=>:destroy
end           

class NCardtype < ActiveRecord::Base  
  set_table_name 'cardtypes'
end

class DatatypeToCardtypeIi < ActiveRecord::Migration
  def self.up
    NCard.find(:all).each do |card| 
      begin
        datatype = card.datatype_key
        cardtype = card.send(:read_attribute, :type)
        datatype.gsub!(/Plaintext/,'PlainText')
        next if datatype=='RichText'
        next if datatype=='User' and cardtype=='User'
        if cardtype!='Basic'
          puts "\n\n*********BOOOM WE HAVE A PROBLEM #{card.name}  dt=#{datatype} ct=#{cardtype}**\n"
        end

        puts "#{card.name}: #{datatype} --> "
        if ct = NCardtype.find_by_class_name(datatype)
          card.type = datatype
          card.save!
        else
          puts "\n\n*** NO CARDTYPE FOR #{datatype} **"
        end
      rescue Exception=>e
        puts "*** Error for card #{card}: #{e.message}"
      end
    end
  end

  def self.down
  end
end
