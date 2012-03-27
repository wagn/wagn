# -*- encoding : utf-8 -*-
require 'open-uri'

class Mailer < ActionMailer::Base
  include LocationHelper

  CHARSET = "utf-8"
  default :charset => CHARSET

  def account_info(user, subject, message)
    #warn "account_info (#{user}, #{subject}, #{message})"
    from_card = Card.user_card
    from_name = from_card.nil? ? '' : from_card.name
    from_user = from_card.to_user || User.admin
    url_key = Card[user.card_id].cardname.to_url_key

    @email    = (user.email    or raise Wagn::Oops.new("Oops didn't have user email"))
    @password = (user.password or raise Wagn::Oops.new("Oops didn't have user password"))
    @card_url = wagn_url Card[user.card_id]
    @pw_url   = wagn_url "/card/options/#{url_key}"
    @login_url= wagn_url "/account/signin"
    @message  = message.clone

    mail( {
      :to       => @email,
      :from     => (Card.setting('*invite+*from') || "#{from_name} <#{from_user.email}>"), #FIXME - might want different from settings for different emails?
      :subject  => subject
    } )
  end

  def signup_alert(invite_request)
    @site = Card.setting('*title')
    @card = invite_request
    @email= invite_request.to_user.email
    @name = invite_request.name
    @content = invite_request.content
    @request_url  = wagn_url invite_request
    @requests_url = wagn_url Card['Account Request']

    mail( {
      :to      => Card.setting('*request+*to'),
      :from    => Card.setting('*request+*from') || @email,
      :subject => "#{invite_request.name} signed up for #{@site}",
      :content_type => 'text/html',
    } )
  end


  def change_notice(user, card, action, watched, subedits=[], updated_card=nil)
    return unless user = User===user ? user : User.from_id(user)

    #warn "change_notice( #{user.email}, #{card.inspect}, #{action.inspect}, #{watched.inspect} Uc:#{updated_card.inspect}...)"
    updated_card ||= card
    @card = card
    @updater = updated_card.updater.name
    @action = action
    @subedits = subedits
    @card_url = wagn_url card
    @change_url = wagn_url "/card/changes/#{card.cardname.to_url_key}"
    @unwatch_url = wagn_url "/card/watch/#{watched.to_cardname.to_url_key}?toggle=off"
    @udpater_url = wagn_url card.updater
    @watched = (watched == card.cardname ? "#{watched}" : "#{watched} cards")

    mail( {
      :to           => "#{user.email}",
      :from         => User.admin.email,
      :subject      => "[#{Card.setting('*title')} notice] #{@updater} #{action} \"#{card.name}\"" ,
      :content_type => 'text/html',
    } )
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
    
    mail config
  end

end

