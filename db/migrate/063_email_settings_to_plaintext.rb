class EmailSettingsToPlaintext < ActiveRecord::Migration
  def self.up                                                                                 
     if c = MCard.find_by_name("invitation email subject") then c.datatype_key="Plaintext"      end
     if c = MCard.find_by_name("invitation email subject") then c.plus_datatype_key="Plaintext" end
     if c = MCard.find_by_name("invitation email body")    then c.datatype_key="Plaintext"      end
     if c = MCard.find_by_name("invitation email body")    then c.plus_datatype_key="Plaintext" end
  end

  def self.down
  end
end                          
