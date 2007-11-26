class AddBuiltinReferenceCards < ActiveRecord::Migration
  def self.up
    User.as :admin do
      {
        "*cards linked to"    => { :linked_to_by =>"_self" },
        "*cards linked from"  => { :link_to => "_self" },
        "*cards included"     => { :included_by =>"_self" },
        "*cards that include" => { :include =>"_self" },
      }.each do |name, spec|
        Card::Search.create! :name=>"#{name}+*template", 
          :content=>spec.to_json, :extension_type=>'HardTemplate'
      end
    end
  end

  def self.down
  end
end
