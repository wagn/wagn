# -*- encoding : utf-8 -*-

class ImportHelpText < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      json = File.read( File.join Wagn.gem_root, 'db/migrate_cards/data/1.11_help_text.json' )
      data = JSON.parse json
      data.each do |atom|
        c = atom['card']
        Card.merge c['name'], { :type=>c['type'], :content=>atom['views'][0]['parts'] }, :pristine=>true
      end      
    end
  end

end
