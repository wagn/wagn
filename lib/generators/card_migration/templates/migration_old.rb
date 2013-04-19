# -*- encoding : utf-8 -*-
load 'db/wagn_migration_helper.rb'
class <%= migration_class_name %> < ActiveRecord::Migration <%# %>
  include WagnMigrationHelper

  def self.up
    [
    <%- @cards.each do |card| %>
      [ "<%= card.name %>", "<%= card.typecode %>", <<CARDCONTENT
<%= card.content %>
CARDCONTENT
      ],
    <%- end %><%# %>
    ].each do |name, typecode, content|
      create_or_update_pristine Card.fetch( name, :new=>{} ), typecode, content.chomp
    end
  end

  def self.down
  end

end
