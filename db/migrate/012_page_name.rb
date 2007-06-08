#load 'card.rb'

class PageName < ActiveRecord::Migration
  class Card < ActiveRecord::Base
    set_table_name 'pages'
    belongs_to :tag
    acts_as_tree
    class_inheritable_accessor :wiki_joint
    self.wiki_joint= '~'
    
    def title_tag_names
      root_cards.plot(:tag).plot(:name)
    end
    
    def root_cards()
      ([self] + self.ancestors).reverse.map {|p| p.tag.root_card } 
    end
  end
  
  class Tag < ActiveRecord::Base
    has_one :root_card, :class_name=>'Card', :conditions => "parent_id IS NULL"
    belongs_to :current_revision, :class_name=>'TagRevision', :foreign_key=>'current_revision_id'
    def name
      current_revision.name
    end
  end
  
  class TagRevision < ActiveRecord::Base
  end
  
  
  def self.up
    add_column :pages, 'name', :string
    Card.find(:all).each do |card|
      card.name = card.title_tag_names.join JOINT
      card.save
    end
  end

  def self.down
    remove_column :pages, 'name'
  end
end
