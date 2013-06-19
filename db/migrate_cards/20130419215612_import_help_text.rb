# -*- encoding : utf-8 -*-

class ImportHelpText < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      # generated JSON from template db with this url:  /*help+*right+by_name.json?view=core&pretty=true
      json = File.read( File.join Rails.root, 'db/migrate_cards/data/1.11_help_text.json' )
      data = JSON.parse json
      Rails.logger.info "parsed!"
      data.each do |atom|
        c = atom['card']
        Card.merge c['name'], { :type=>c['type'], :content=>atom['views'][0]['parts'] }, :pristine=>true
      end      
    end
  end

  def down
    contentedly do
      
    end
  end
end
