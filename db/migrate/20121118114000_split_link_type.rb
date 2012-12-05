require_dependency 'chunks/chunk'
require_dependency 'chunk_manager'

class SplitLinkType < ActiveRecord::Migration
  include Card::ReferenceTypes

  # Needed for migration
  LINK_TYPES       = [ 'L', 'W' ]
  TRANSCLUDE_TYPES = [ 'T', 'M' ]

  MISSING    = [ LINK_TYPES.last,  TRANSCLUDE.last  ]
  PRESENT    = [ LINK_TYPES.first, TRANSCLUDE.first ]

  def up
    add_column :card_references, :present, :integer
    Card::Reference.where(:link_type=>LINK_TYPES.last).      update_all(:present=>0, :link_type=>LINK_TYPES.first)
    Card::Reference.where(:link_type=>TRANSCLUDE_TYPES.last).update_all(:present=>0, :link_type=>TRANSCLUDE_TYPES.first)
    Card::Reference.where(:link_type=>PRESENT).              update_all(:present=>1)
  end

  def down
    Card::Reference.where(:present=>0, :link_type=>LINK_TYPES.first).      update_all(:link_type=>LINK_TYPES.last)
    Card::Reference.where(:present=>0, :link_type=>TRANSCLUDE_TYPES.first).update_all(:link_type=>TRANSCLUDE_TYPES.last)
    remove_column :card_references, :present
  end
end
