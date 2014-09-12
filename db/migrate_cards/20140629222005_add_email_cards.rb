# -*- encoding : utf-8 -*-

class SystemEmails < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      # create new cardtype for email templates
      Card.create! :name=>"Email template", :codename=>:email_template, :type_id=>Card::CardtypeID
      Card.create! :name=>"Email template+*type+*structure", :content=> "{{+*from}}\n{{+*to}}\n{{+*cc}}\n{{+*bcc}}\n{{+*subject}}\n{{+*html message}}\n{{+*text message}}\n{{+*attach}}"
      if email_config=Card.fetch("email_config+*right+*structure")
        email_config.update_attributes( 
          :content=>"{{+*from}}\n{{+*to}}\n{{+*cc}}\n{{+*bcc}}\n{{+*subject}}\n{{+*html message}}\n{{+*text message}}\n{{+*attach}})"
        )
      end
      
      # create system email cards
      dir = "#{Wagn.gem_root}/db/migrate_cards/data/mailer"
      json = File.read( File.join( dir, 'mail_config.json' ))
      data = JSON.parse(json)
      data.each do |mail|
        mail = mail.symbolize_keys!
        Card.create! :name=> mail[:name], :codename=>mail[:codename], :type=>:email_template
        Card.create! :name=>"#{mail[:name]}+*html message", :content=>File.read( File.join( dir, "#{mail[:codename]}.html" ))
        Card.create! :name=>"#{mail[:name]}+*text message", :content=>File.read( File.join( dir, "#{mail[:codename]}.txt" ))
        Card.create! :name=>"#{mail[:name]}+*subject", :content=>mail[:subject] 
      end
      
      # change notification rules
      %w( create update delete ).each do |action|
        Card.create! :name => "*on #{action}", :type_code=>:setting, :codename=>"on_#{action}"
        Card.create! :name => "*on #{action}+*right+*help", :content=>"Configures email to be sent when card is #{action}d."
        Card.create! :name => "*on #{action}+*right+*default", :type_code=>:pointer, 
                     :content=>"[[_left+email config]]"
      end
      
      # the new watch rule
      Card.create! :name => '*following', :type_code=>:pointer, :codename=>'following'
      Card.create! :name => '*following+*right+*default', :type_code=>:pointer
      
      # move old send rule to on_create
      fields = %w( to from cc bcc subject message attach )
      Card.search(:right=>"*send").each do |send_rule|
        Card.create! :name=>"send_rule.left+*on create", :content=>send_rule.content, :type_code=>:pointer
        #send_rule.delete  #@ethn: keep old rule for safety reasons?
      end
      
    end
  end
end
