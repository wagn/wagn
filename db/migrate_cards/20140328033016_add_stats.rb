# -*- encoding : utf-8 -*-

#TEMPORARY - delete me before 1.13!
# (but add permission migration)
# ( and right structure)

=begin
class AddStats < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      [ :stats ].each do |codename|
        Card.create! :name=>"*#{codename}", :codename=>codename
      end
    end
  end
end
=end