require_dependency 'db/migration_helper'

class AddCardtypesForDatatypes < ActiveRecord::Migration
  include MigrationHelper
  
  def self.up
    ## FIXME -- holy hack!
    create_table :permissions do |t|
        t.column 'card_id', :integer
        t.column 'task', :string
        t.column 'party_type', :string
        t.column 'party_id', :integer
    end
    
    
    Card.reset_column_information
    Card::Cardtype.reset_column_information
    
    add_cardtype "Currency"   ,"Currency"
    add_cardtype "Date"       ,"Date"
    add_cardtype "File"       ,"File"
    add_cardtype "Image"      ,"Image"
    add_cardtype "Number"     ,"Number"
    add_cardtype "Percentage" ,"Percentage"
    add_cardtype "PlainText"  ,"PlainText"
    add_cardtype "Query"      ,"Query"
    add_cardtype "Ruby"       ,"Ruby"
    add_cardtype "Script"     ,"Script"
    
    
  end

  def self.down
  end
end
