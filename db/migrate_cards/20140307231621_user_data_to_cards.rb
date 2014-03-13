# -*- encoding : utf-8 -*-

class User < ActiveRecord::Base
end

class UserDataToCards < ActiveRecord::Migration
  include Wagn::MigrationHelper  
  
  def up
    contentedly do
      
      # add new codename cards
      [ :password, :token, :salt, :status, :signin ].each do |codename|
        Card.create! :name=>"*#{codename}", :codename=>codename
      end
      
      Card::Codename.reset_cache
      
      # set create permissions for account cards (inherit from left)
      [ :password, :token, :salt, :status, :email, :account ].each do |codename|
        rule_name = [ codename, :right, :create ].map { |code| Card[code].name } * '+'
        rule_card = Card.fetch rule_name, :new=>{}
        rule_card.content = '_left'
        rule_card.save!
      end
      
      # make email and password fields default to Phrase cards
      [:email, :password].each do |field|
        rulename = [field, :right, :default].map { |code| Card[code].name } * '+'
        Card.create! :name=>rulename, :type_id=>Card::PhraseID
      end
      
      # turn captcha off by default
      rulename = [:all, :captcha].map { |code| Card[code].name } * '+'
      captcha_rule = Card.fetch rulename, :new=>{}
      captcha_rule.content = 0
      captcha_rule.save!
      
      # support legacy handling of +*email on User cards
      oldname = [       :email,           :right, :structure].map { |code| Card[code].name } * '+'
      newname = [:user, :email, :type_plus_right, :structure].map { |code| Card[code].name } * '+'
      Card[oldname].update_attributes! :name=>newname
      
      
      # import all user details (for those not in trash) into +*account attributes
      User.all.each do |user|
        base = Card[user.card_id]
        if base and !base.trash
          date_args = { :created_at => user.created_at, :updated_at => user.updated_at }
          [ :email, :password, :salt, :status ].each do |field|
            cardname = "#{base.name}+#{Card[:account].name}+#{Card[field].name}"
            if content = user.send ( field==:password ? :crypted_password : field )
              Card.create! date_args.merge( :name=>cardname, :content=>content)
            end
          end
        end
      end
      
      
    end
  end

end
