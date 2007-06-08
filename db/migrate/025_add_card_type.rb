module Node

  class Base < ActiveRecord::Base
    set_table_name 'nodes'
  end
  class Company  < Base; end
  class Wiki     < Base; end
  class Template < Base; end
  class User     < Base; end
  class Basic    < Base; end
  class Nodetype < Base; end
  
end

class AddCardType < ActiveRecord::Migration
  class Card < ActiveRecord::Base
    belongs_to :tag
    set_inheritance_column ''
    acts_as_tree
    def simple?() self.parent.nil? end
  end
  
  class Tag < ActiveRecord::Base
    belongs_to :node, :polymorphic => true
  end

  def self.up
    add_column :cards, 'type', :string
    add_column :cards, :extension_id, :integer
    add_column :cards, :extension_type, :string
    Card.find(:all).each do |card|
      if card.simple?
        node_type = card.tag.node_type || 'Basic'
        if node_type.match(/^Node::/)
          type = card.tag.node.type.to_s
        else
          type = node_type.to_s
          card.extension_id =  card.tag.node_id
          card.extension_type = node_type
          card.save
        end
      else
        type = 'Connection'
      end
      type.gsub!(/^Node::/,'')
      type.gsub!(/Wiki/,'Basic')
      type.gsub!(/NilClass/,'Basic')  # what?!
      execute %{ update cards set type='#{type}' where id=#{card.id} }
      
    end
    execute %{ alter table tags alter column node_id drop not null }
    execute %{ alter table tags alter column node_type drop not null }

  end

  def self.down
    remove_column :cards, :type
    remove_column :cards, :extension_id
    remove_column :cards, :extension_type
  end
end
