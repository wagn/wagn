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


    def confirmation_email account
      config = render_mail_config( Card["confirmation email"],
        :locals=>{
          :link        => wagn_url( "/update/#{account.left.cardname.url_key}?token=#{account.token}" ),
          :expiry_days => Wagn.config.token_expiry / 1.day 
        }).merge :to=>account.email 
      confirm_from = token_emails_from(account)
      mail_from( config, confirm_from ) 
    end
  
    def password_reset account
      config = render_mail_config( Card['password reset'], :locals=>{
          :link        => wagn_url( "/update/#{account.cardname.url_key}?reset_token=#{account.token_card.refresh(true).content}" ),
          :expiry_days => Wagn.config.token_expiry / 1.day,
        }).merge :to=>account.email
      reset_from = token_emails_from(account)
      mail_from( config, reset_from )    
    end

    def signup_alert invite_request
      config = render_mail_config( Card['invite request'], 
        :locals=>{
          :email        => invite_request.account.email,
          :name         => invite_request.name,
          :request_url  => wagn_url( invite_request ),
          :requests_url => wagn_url( Card[:signup] ),
        }).merge :to=>Card.setting('*request+*to')
      mail_from( config, Card.setting('*request+*from') || "#{@name} <#{@email}>" )
    end


    def change_notice cd_with_acct, card, action, watched, subedits=[], updated_card=nil
      cd_with_acct = Card[cd_with_acct] unless Card===cd_with_acct
      email = cd_with_acct.account.email
      #warn "change_notice( #{cd_with_acct}, #{email}, #{card.inspect}, #{action.inspect}, #{watched.inspect} Uc:#{updated_card.inspect}...)"

      updated_card ||= card
      config = render_mail_config( Card['change notice'], 
        :locals=>{
          :name => card.name,
          :updater => updated_card.updater.name,
          :action => action,
          :subedits => subedits,
          :card_url => wagn_url( card ),
          :change_url  => wagn_url( "card/changes/#{card.cardname.url_key}" ),
          :unwatch_url => wagn_url( "card/watch/#{watched.to_name.url_key}?toggle=off" ),
          :udpater_url => wagn_url( card.updater ),
          :watched => (watched == card.cardname ? "#{watched}" : "#{watched} cards"),
        }).merge( :to => email )
      mail_from( config, Card[Card::WagnBotID].account.email )
    end

    def flexmail config
      config.merge!( render_mail_config Card['email layout'], 
                        { :message => config.delete(:message) } )

      if attachment_list = config.delete(:attach) and !attachment_list.empty?
        attachment_list.each_with_index do |cardname, i|
          if c = Card[ cardname ] and c.respond_to?(:attach)
            attachments["attachment-#{i + 1}.#{c.attach_extension}"] = File.read( c.attach.path )
          end
        end
      end
      mail_from config, config[:from]
    end

    def cardmail config  # only for testing, remove at the end
      args = config.merge( { content_type: "text/plain" } )
      mail( config_sender(args, Card[Card::WagnBotID].account.email) )  do |format|
        format.text { ERB.new('<%="test"%>').result }
      end
    end
    
    private
    
    def render_mail_config card, args
      card.format(:format => :email)._render_config args #TODO which format?
    end

    def token_emails_from account
      Card.setting( '*invite+*from' ) || begin
        from_card_id = Auth.current_id
        from_card_id = WagnBotID if [ AnonymousID, account.left_id ].member? from_card_id
        from_card = Card[from_card_id]
        "#{from_card.name} <#{from_card.account.email}>"
      end
    end
    
    def config_sender args, from
      from_name, from_email = (from =~ /(.*)\<(.*)>/) ? [$1.strip, $2] : [nil, from]
      
      if default_from=@@defaults[:from]
        args[:from] = !from_email ? default_from : "#{from_name || from_email} <#{default_from}>"
        args[:reply_to] ||= from
      else
        args[:from] = from
      end
      return args
    end
    
    def mail_from args, from, &block
      args = config_sender( args, from )
      #args[:template_path] = 'mailer'
      mail args, &block 
    end

  end
  
end
