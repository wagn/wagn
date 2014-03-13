# -*- encoding : utf-8 -*-

class LegacyEmailCardStructure < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      oldname = [       :email,           :right, :structure].map { |code| Card[code].name } * '+'
      newname = [:user, :email, :type_plus_right, :structure].map { |code| Card[code].name } * '+'
      
      Card[oldname].update_attributes! :name=>newname
    end
  end
end
