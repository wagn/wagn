# encoding: utf-8
load 'db/wagn_migration_helper.rb'
class PointerInputOptions < ActiveRecord::Migration 
  include WagnMigrationHelper

  def self.up
    [

      [ "*input+*right+*default", "Pointer", <<CARDCONTENT

CARDCONTENT
      ],

      [ "*input+*right+*options", "Pointer", <<CARDCONTENT
[[radio]]
[[checkbox]]
[[select]]
[[multiselect]]
[[list]]
CARDCONTENT
      ],

      [ "*input+*right+*input", "Phrase", <<CARDCONTENT
radio
CARDCONTENT
      ],

      [ "*input+*right+*edit help", "Basic", <<CARDCONTENT
<p>The type of editor for a set of [[Pointer]] cards.</p>
CARDCONTENT
      ],

    ].each do |name, typecode, content|
      create_or_update_pristine Card.fetch_or_new(name), typecode, content.chomp
    end
  end

  def self.down
  end

end
