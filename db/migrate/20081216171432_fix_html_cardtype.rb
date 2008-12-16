class FixHtmlCardtype < ActiveRecord::Migration
  def self.up
    if c = Cardtype.find_by_class_name("HTML1")
      unless Cardtype.find_by_class_name("HTML")
        c.class_name = "HTML"
        c.save!
      end
    end
  end

  def self.down
  end
end
