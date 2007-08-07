require_dependency 'db/card_creator.rb'

class DatatypeSetup < ActiveRecord::Migration
  def self.up
    #rename_column :tags, :datatype, :datatype_id
    add_column :tags, :datatype_key, :string
    add_column :tags, :plus_datatype_key, :string           
    
    MTag.find(:all).each do |tag|
      tag.datatype_key = "RichText"
      tag.plus_datatype_key = "RichText"
      tag.save
    end
    change_column :tags, :datatype_key, :string, :null => false, :default => "RichText"
    change_column :tags, :plus_datatype_key, :string, :null => false, :default => "RichText"  
    
    #execute("update tags set datatype_key='RichText'")
    #execute("update tags set plus_datatype_key='RichText'")
    ## FIXME: postgres-specific?
    #execute("alter table tags alter column datatype_key set not null")
    #execute("alter table tags alter column plus_datatype_key set not null")
    
    # TODO:
    # remove_column :tags, :datatype
  end

  def self.down
    remove_column :tags, :datatype_key
    remove_column :tags, :plus_datatype_key
  end
end
