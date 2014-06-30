# -*- encoding : utf-8 -*-

class MailSettings < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      Card.create! :name => '*on create', :type_code=>:setting, :codename=>'on_create'
      Card.create! :name => '*on update', :type_code=>:setting, :codename=>'on_update'
      Card.create! :name => '*on delete', :type_code=>:setting, :codename=>'on_delete'
    end
  end
end
