# -*- encoding : utf-8 -*-
require 'open-uri'

class Mailer < ActionMailer::Base
  @@defaults = Wagn.config.email_defaults || {}
  @@defaults.symbolize_keys!
  @@defaults[:return_path] ||= @@defaults[:from] if @@defaults[:from]
  @@defaults[:charset] ||= 'utf-8'
  default @@defaults

  include Wagn::Location


  def account_info cd_with_acct, args
    @email, subject, @message, @password = [:to, :subject, :message, :password].map do |k|
      args[k] or raise "Missing email parameter: #{k}"
    end

    @pw_url   = wagn_url "#{cd_with_acct.cardname.url_key}?view=account"
    @login_url= wagn_url "account/signin"

    #FIXME - might want different "from" settings for different contexts?
    invite_from = Card.setting( '*invite+*from' ) || begin
      from_card_id = Account.current_id
      from_card_id = Card::WagnBotID if [ Card::AnonID, cd_with_acct.id ].member? from_card_id
      from_card = Card[from_card_id]
      "#{from_card.name} <#{from_card.account.email}>"
    end
    
    mail_from( { :to=>@email, :subject=>subject }, invite_from )
  end

  def signup_alert invite_request
    @site = Card.setting :title
    @card = invite_request
    @email= invite_request.account.email
    @name = invite_request.name
    @content = invite_request.content
    @request_url  = wagn_url invite_request
    @requests_url = wagn_url Card['Account Request']

    args = {
      :to           => Card.setting('*request+*to'),
      :subject      => "#{invite_request.name} signed up for #{@site}",
      :content_type => 'text/html',
    }
    mail_from args, Card.setting('*request+*from') || "#{@name} <#{@email}>"
  end


  def change_notice cd_with_acct, card, action, watched, subedits=[], updated_card=nil
    cd_with_acct = Card[cd_with_acct] unless Card===cd_with_acct
    email = cd_with_acct.account.email
    #warn "change_notice( #{cd_with_acct}, #{email}, #{card.inspect}, #{action.inspect}, #{watched.inspect} Uc:#{updated_card.inspect}...)"

    updated_card ||= card
    @card = card
    @updater = updated_card.updater.name
    @action = action
    @subedits = subedits
    @card_url = wagn_url card
    @change_url  = wagn_url "card/changes/#{card.cardname.url_key}"
    @unwatch_url = wagn_url "card/watch/#{watched.to_name.url_key}?toggle=off"
    @udpater_url = wagn_url card.updater
    @watched = (watched == card.cardname ? "#{watched}" : "#{watched} cards")

    args = {
      :to           => email,
      :subject      => "[#{Card.setting :title} notice] #{@updater} #{action} \"#{card.name}\"" ,
      :content_type => 'text/html',
    }
    mail_from args, Card[Card::WagnBotID].account.email
  end

  def flexmail config
    @message = config.delete(:message)

    if attachment_list = config.delete(:attach) and !attachment_list.empty?
      attachment_list.each_with_index do |cardname, i|
        if c = Card[ cardname ] and c.respond_to?(:attach)
          attachments["attachment-#{i + 1}.#{c.attach_extension}"] = File.read( c.attach.path )
        end
      end
    end

    mail_from config, config[:from]
  end

  private

  def mail_from args, from
    #puts "unprocessed mail args: #{args}"
    unless ENV['WAGN_MIGRATION']
      from_name, from_email = (from =~ /(.*)\<(.*)>/) ? [$1.strip, $2] : [nil, from]
      if default_from=@@defaults[:from]
        args[:from] = !from_email ? default_from : "#{from_name || from_email} <#{default_from}>"
        args[:reply_to] ||= from
      else
        args[:from] = from
      end
      #puts "mail args: #{args}"
      mail args
    end
  end


end

