require 'open-uri'

class Mailer < ActionMailer::Base
  include LocationHelper
  def account_info(user, subject, message)
    from_user = User.current_user || User[:wagbot]
    from_name = from_user.card ? from_user.card.cardname : ''
    url_key = user.card.cardname.to_url_key

    @email    = (user.email    or raise Wagn::Oops.new("Oops didn't have user email"))
    @password = (user.password or raise Wagn::Oops.new("Oops didn't have user password"))
    @card_url = wagn_url user.card
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
    @email= invite_request.extension.email
    @name = invite_request.name
    @content = invite_request.content
    @request_url  = wagn_url invite_request
    @requests_url = wagn_url Card['Account Request']

    mail( {
      :to      => Card.setting('*request+*to'),
      :from    => Card.setting('*request+*from') || invite_request.extension.email,
      :subject => "#{invite_request.name} signed up for #{@site}",
      :content_type => 'text/html',
    } )
  end               

  
  def change_notice( user, card, action, watched, subedits=[], updated_card=nil )       
    #warn "change_notice( #{user}, #{card.inspect}, #{action}, #{watched} ...)"
    updated_card ||= card
    @card = card
    @updater = updated_card.updater.card.name
    @action = action
    @subedits = subedits
    @card_url = wagn_url card
    @change_url = wagn_url "/card/changes/#{card.cardname.to_url_key}"
    @unwatch_url = wagn_url "/card/watch/#{watched.to_cardname.to_url_key}?toggle=off"
    @udpater_url = wagn_url card.updater.card
    @watched = (watched == card.cardname ? "#{watched}" : "#{watched} cards")

    mail( {
      :to           => "#{user.email}",
      :from         => User.find_by_login('wagbot').email,
      :subject      => "[#{Card.setting('*title')} notice] #{@updater} #{action} \"#{card.name}\"" ,
      :content_type => 'text/html',
    } )
  end
  
  def flexmail config
    
    if config[:attach] and !config[:attach].empty?
      # FIXME - this doesn't look fully converted to me.
      config[:attach].each do |cardname|
        if c = Card[ cardname ] and c.respond_to?(:attachment) and cardfile = c.attachment
          attachment cardfile.content_type do |a|
            open( cardfile.public_filename ) do |f|
              a.filename cardfile.filename
              a.body = f.read
            end
          end
        end
      end
    else
      config[:content_type] = 'text/html'
      config[:body] = config.delete(:message)
    end
    
    mail(config)
  end
  
end

