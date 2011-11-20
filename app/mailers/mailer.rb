require 'open-uri'

class Mailer < ActionMailer::Base
  def account_info(user, subject, message)
    from_user = User.current_user || User[:wagbot]
    from_name = from_user.card ? from_user.card.cardname : ''
    url_key = user.card.cardname.to_url_key

    @email    = (user.email    or raise Wagn::Oops.new("Oops didn't have user email"))
    @password = (user.password or raise Wagn::Oops.new("Oops didn't have user password"))
    @card_url = "#{System.base_url}#{System.root_path}/wagn/#{url_key}"
    @pw_url   = "#{System.base_url}#{System.root_path}/card/options/#{url_key}"
    @login_url= "#{System.base_url}#{System.root_path}/account/signin"
    @message  = message.clone

    mail( {
      :recipients => "#{user.email}",
      :from       => (System.setting('*invite+*from') || "#{from_name} <#{from_user.email}>"), #FIXME - might want different from settings for different emails?
      :subject      => subject
    } )
  end                 
  
  def signup_alert(invite_request)  
    @site = System.site_title
    @card = invite_request
    @email= invite_request.extension.email
    @name = invite_request.name
    @content = invite_request.content
    @url  = url_for(:host=>System.host, :controller=>'card', :action=>'show', :id=>invite_request.cardname.to_url_key)

    mail( {
    :recipients => System.setting('*request+*to'),
    :from        => System.setting('*request+*from') || invite_request.extension.email,
    :subject => "#{invite_request.name} signed up for #{@site}",
    :content_type => 'text/html',
    } )
  end               

  
  def change_notice( user, card, action, watched, subedits=[], updated_card=nil )       
    #warn "change_notice( #{user}, #{card.inspect} ...)"
    updated_card ||= card
    @card = card
    @updater = updated_card.updater.card.name
    @action = action
    @subedits = subedits
    @card_url = "#{System.base_url}/wagn/#{card.cardname.to_url_key}"
    @change_url = "#{System.base_url}/card/changes/#{card.cardname.to_url_key}"
    @unwatch_url = "#{System.base_url}/card/unwatch/#{watched.to_cardname.to_url_key}"
    @udpater_url = "#{System.base_url}/wagn/#{card.updater.card.cardname.to_url_key}"
    @watched = (watched == card.cardname ? "#{watched}" : "#{watched} cards")

    mail( {
      :to           => "#{user.email}",
      :from         => User.find_by_login('wagbot').email,
      :subject      => "[#{System.setting('*title')} notice] #{@updater} #{action} \"#{card.name}\"" ,
      :content_type => 'text/html',
    } )
  end
  
  def flexmail config
    
    if config[:attach] and !config[:attach].empty?
      
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
    end
    config[:body] = config.delete(:message)
    mail(config)
  end
  
end

