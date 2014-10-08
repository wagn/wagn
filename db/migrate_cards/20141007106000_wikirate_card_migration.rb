# -*- encoding : utf-8 -*-

class WikirateCardMigration < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      if card = Card.fetch("Email template+*type+*structure")
        card.update_attributes! :content=>"{{+*from|titled}}\n{{+*to|titled}}\n{{+*cc|titled}}\n{{+*bcc|titled}}\n{{+*subject|titled}}\n{{+*html message|titled}}\n{{+*text message|titled}}\n{{+*attach|titled}})"
      end
      Card.create! :name=>"*text message+*right+*default", :type_code=>:plain_text
      if email_config=Card.fetch("email_config+*right+*structure")
        email_config.update_attributes!( 
          :content=>"{{+*from|titled}}\n{{+*to|titled}}\n{{+*cc|titled}}\n{{+*bcc|titled}}\n{{+*subject|titled}}\n{{+*html message|titled}}\n{{+*text message|titled}}\n{{+*attach|titled}})"
        )
      end

      dir = "#{Wagn.gem_root}/db/migrate_cards/data/mailer"
      json = File.read( File.join( dir, 'mail_config.json' ))
      data = JSON.parse(json)
      data.each do |mail|
        mail = mail.symbolize_keys!
        card = Card.fetch mail[:name]
        card.update_attributes! :type_id=>Card::EmailTemplateID
      end
    end
  end
end

