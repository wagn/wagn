require_dependency 'chunks/chunk'
require_dependency 'chunk_manager'

class UpdateLinkType < ActiveRecord::Migration
  def up
    Card::Reference.update_all(:present=>1)
    Card::Reference.where(:link_type=>'T').update_all(:link_type=>'I')
    Card::Reference.where(:link_type=>'M').update_all(:present=>0, :link_type=>'L')
    Card::Reference.where(:link_type=>'W').update_all(:present=>0, :link_type=>'I')
  end

  def down
    Card::Reference.where(:present=>0, :link_type=>'L').   update_all(:link_type=>'M')
    Card::Reference.where(:present=>0, :link_type=>'I').update_all(:link_type=>'W')
    Card::Reference.where(:present=>1, :link_type=>'I').update_all(:link_type=>'T')
  end
end
