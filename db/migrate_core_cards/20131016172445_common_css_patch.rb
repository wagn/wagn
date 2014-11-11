# -*- encoding : utf-8 -*-

class CommonCssPatch < Wagn::Migration
  def up
    dir = "#{Wagn.gem_root}/db/migrate_cards/data/1.12_stylesheets"
    card = Card["style: common"]
    if card && card.pristine?
      card.update_attributes! :content=>File.read("#{dir}/common.scss")
    end
  end

end
