# -*- encoding : utf-8 -*-

class MoveStylesToContent < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      dir = "#{Wagn.gem_root}/db/migrate_cards/data/1.12_stylesheets"
      %w{ right_sidebar common classic_cards traditional }.each do |sheetname|
        Card["style: #{sheetname}"].update_attributes! :codename=>nil, :content=>File.read("#{dir}/#{sheetname}.scss")
      end
    end
  end

end
