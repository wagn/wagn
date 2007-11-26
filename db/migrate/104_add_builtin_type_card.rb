class AddBuiltinTypeCard < ActiveRecord::Migration
  def self.up
    User.as :admin do
      {
        "*type cards"    => { :type =>"_self" }
      }.each do |name, spec|
        Card::Search.create! :name=>"#{name}+*template", 
          :content=>spec.to_json, :extension_type=>'HardTemplate'
      end
    end
  end

  def self.down
  end
end
