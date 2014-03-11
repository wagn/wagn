# -*- encoding : utf-8 -*-

class AccountAndSessionCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      [ :session, :password, :token, :salt, :status ].each do |codename|
        Card.create! :name=>"*#{codename}", :codename=>codename
      end
    end
  end

end
