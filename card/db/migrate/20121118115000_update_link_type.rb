# -*- encoding : utf-8 -*-
class UpdateLinkType < ActiveRecord::Migration
  class TmpReference < ActiveRecord::Base
    self.table_name = "card_references"
  end

  def up
    TmpReference.update_all(present: 1)
    TmpReference.where(link_type: "T").update_all(link_type: "I")
    TmpReference.where(link_type: "M").update_all(present: 0, link_type: "L")
    TmpReference.where(link_type: "W").update_all(present: 0, link_type: "I")
  end

  def down
    TmpReference.where(present: 0, link_type: "L").update_all(link_type: "M")
    TmpReference.where(present: 0, link_type: "I").update_all(link_type: "W")
    TmpReference.where(present: 1, link_type: "I").update_all(link_type: "T")
  end
end
