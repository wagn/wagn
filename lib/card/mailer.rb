# -*- encoding : utf-8 -*-
require 'open-uri'

class Card
  class Mailer < ActionMailer::Base
    
    @@defaults = Wagn.config.email_defaults || {}
    @@defaults.symbolize_keys!
    @@defaults[:return_path] ||= @@defaults[:from] if @@defaults[:from]
    @@defaults[:charset] ||= 'utf-8'
    default @@defaults

    include Wagn::Location

    def change_notice cd_with_acct, card, action, watched, subedits=[], updated_card=nil
      cd_with_acct = Card[cd_with_acct] unless Card===cd_with_acct
      email = cd_with_acct.account.email
      #warn "change_notice( #{cd_with_acct}, #{email}, #{card.inspect}, #{action.inspect}, #{watched.inspect} Uc:#{updated_card.inspect}...)"

      updated_card ||= card
      Card['change notice'].format(:format=>:email)._render_mail(
        :to     => email,
        :from   => Card[Card::WagnBotID].account.email,
        :locals => {
                    :name => card.name,
                    :updater => updated_card.updater.name,
                    :action => action,
                    :subedits => subedits,
                    :card_url => wagn_url( card ),
                    :change_url  => wagn_url( "card/changes/#{card.cardname.url_key}" ),
                    :unwatch_url => wagn_url( "card/watch/#{watched.to_name.url_key}?toggle=off" ),
                    :udpater_url => wagn_url( card.updater ),
                    :watched => (watched == card.cardname ? "#{watched}" : "#{watched} cards"),
                   }).deliver
    end

    def mail_layout args
      config = render_mail_config( Card['email layout'], 
                  args,
                  :message => args.delete(:message)  )
      
      mail config
    end
  end
end
