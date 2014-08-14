# -*- encoding : utf-8 -*-

class SystemEmails < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      Card.create! :name=>"Email template", :codename=>:email_template, :type_id=>Card::CardtypeID
      Card.create! :name=>"Email template+*type+*structure", :content=> "{{+*from}}\n{{+*to}}\n{{+*cc}}\n{{+*bcc}}\n{{+*subject}}\n{{+*message}}\n{{+*attach}}"

      dir = "#{Wagn.gem_root}/db/migrate_cards/data/mailer"
      json = File.read( File.join( dir, 'mail_config.json' ))
      data = JSON.parse(json)
      data.each do |mail|
        mail = mail.symbolize_keys!
        Card.create! :name=> mail[:name], :codename=>mail[:codename], :type=>:email_template
        Card.create! :name=>"#{mail[:name]}+*message", :content=>File.read( File.join( dir, mail[:message] ))
        Card.create! :name=>"#{mail[:name]}+*subject", :content=>mail[:subject] 
      end
      
      Card.create! :name => '*on create', :type_code=>:setting, :codename=>'on_create'
      Card.create! :name => '*on update', :type_code=>:setting, :codename=>'on_update'
      Card.create! :name => '*on delete', :type_code=>:setting, :codename=>'on_delete'
      Card.create! :name => '*on save',   :type_code=>:setting, :codename=>'on_save'
      Card.create! :name => '*on action', :type_code=>:setting, :codename=>'on_action'
      Card.create! :name => '*hourly',    :type_code=>:setting, :codename=>'hourly'
      Card.create! :name => '*daily',     :type_code=>:setting, :codename=>'daily'
      Card.create! :name => '*weekly',    :type_code=>:setting, :codename=>'weekly'
      Card.create! :name => '*monthly',   :type_code=>:setting, :codename=>'monthly'
    end
  end
end
