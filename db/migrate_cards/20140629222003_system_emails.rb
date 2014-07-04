# -*- encoding : utf-8 -*-

class SystemEmails < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      Card.create! :name=>"Email template", :codename=>:email_template, :type_id=>Card::CardtypeID
      
      dir = "#{Wagn.gem_root}/db/migrate_cards/data/mailer"
      json = File.read( File.join( dir, 'mail_config.json' ))
      data = JSON.parse(json)
      data.each do |mail|
        mail = mail.symbolize_keys!
        Card.create! :name=> mail[:name], :codename=>mail[:codename], :type=>:email_template
        Card.create! :name=>"#{mail[:name]}+*message", :content=>File.read( File.join( dir, mail[:message] ))
        Card.create! :name=>"#{mail[:name]}+*subject", :content=>mail[:subject] 
      end
    end
  end
end
