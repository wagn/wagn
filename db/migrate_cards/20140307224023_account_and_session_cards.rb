# -*- encoding : utf-8 -*-

class AccountAndSessionCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      [ :password, :token, :salt, :status, :session ].each do |codename|
        Card.create! :name=>"*#{codename}", :codename=>codename
      end
      Wagn::Cache.reset_global
      [ :password, :token, :salt, :status, :email, :account ].each do |codename|
        rule_name = [ codename, :right, :create ].map { |code| Card[code].name } * '+'
        rule_card = Card.fetch rule_name, :new=>{}
        rule_card.content = '_left'
        rule_card.save!
      end
    end
  end

end
