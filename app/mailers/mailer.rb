require 'open-uri'

class Mailer < ActionMailer::Base
  def account_info(user, subject, message)
    from_card = Card.user_card
    from_name = from_card.nil? ? '' : from_card.name
    from_user = User.where(:card_id=>from_card.id).first || User.admin
    url_key = user.card.cardname.to_url_key

    @email    = (user.email    or raise Wagn::Oops.new("Oops didn't have user email"))
    @password = (user.password or raise Wagn::Oops.new("Oops didn't have user password"))
    @card_url = "#{Wagn::Conf[:base_url]}#{Wagn::Conf[:root_path]}/#{url_key}"
    @pw_url   = "#{Wagn::Conf[:base_url]}#{Wagn::Conf[:root_path]}/card/options/#{url_key}"
    @login_url= "#{Wagn::Conf[:base_url]}#{Wagn::Conf[:root_path]}/account/signin"
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
    @email= User.where(:card_id=>invite_request.id).first.email
    @name = invite_request.name
    @content = invite_request.content
    @url  = url_for(:host=>Wagn::Conf[:host], :controller=>'card', :action=>'show', :id=>invite_request.cardname.to_url_key)

    mail( {
      :to      => Card.setting('*request+*to'),
      :from    => Card.setting('*request+*from') || @email,
      :subject => "#{invite_request.name} signed up for #{@site}",
      :content_type => 'text/html',
    } )
  end


  def change_notice(user, card, action, watched, subedits=[], updated_card=nil)
    return unless user = User===user ? user : User.where(:card_id=>user).first

    #warn "change_notice( #{user.inspect}, #{card.inspect}, #{action.inspect}, #{watched.inspect} Uc:#{updated_card.inspect}...)"
    updated_card ||= card
    @card = card
    @updater = updated_card.updater.name
    @action = action
    @subedits = subedits
    @card_url = "#{Wagn::Conf[:base_url]}#{Wagn::Conf[:root_path]}/#{card.cardname.to_url_key}"
    @change_url = "#{Wagn::Conf[:base_url]}#{Wagn::Conf[:root_path]}/card/changes/#{card.cardname.to_url_key}"
    @unwatch_url = "#{Wagn::Conf[:base_url]}#{Wagn::Conf[:root_path]}/card/watch/#{watched.to_cardname.to_url_key}?toggle=off"
    @udpater_url = "#{Wagn::Conf[:base_url]}#{Wagn::Conf[:root_path]}/#{card.updater.cardname.to_url_key}"
    @watched = (watched == card.cardname ? "#{watched}" : "#{watched} cards")

    mail( {
      :to           => "#{user.email}",
      :from         => User.where(:card_id=>Card::WagbotID).first.email,
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

