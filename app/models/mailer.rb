class Mailer < ActionMailer::Base
  def account_info(user, subject, message)
    from_user = User.current_user || User[:wagbot]
    from_name = from_user.card ? from_user.card.name : ''
    url_key = user.card.name.to_url_key

    recipients "#{user.email}"
    from       (System.setting('*account+*from') || "#{from_name} <#{from_user.email}>") #FIXME - might want different from settings for different emails?
    subject    subject
    sent_on    Time.now
    body  :email    => (user.email    or raise Wagn::Oops.new("Oops didn't have user email")),
          :password => (user.password or raise Wagn::Oops.new("Oops didn't have user password")),
          
          :card_url => "#{System.base_url}/wagn/#{url_key}",
          :pw_url   => "#{System.base_url}/card/options/#{url_key}",
          
          :login_url=> "#{System.base_url}/account/signin",
          :message  => message.clone
  end                 
  
  def signup_alert(invite_request)  
    recipients  System.setting('*request+*to')
    from        System.setting('*request+*from') || invite_request.extension.email
    subject "#{invite_request.name} signed up for #{System.site_title}"
    content_type 'text/html'
    body  :site => System.site_title,
          :card => invite_request,
          :email => invite_request.extension.email,
          :name => invite_request.name,
          :content => invite_request.content,
          :url =>  url_for(:host=>System.host, :controller=>'card', :action=>'show', :id=>invite_request.name.to_url_key)
  end               

  
  def change_notice( user, card, action, watched, subedits=[], updated_card=nil )       
    updated_card ||= card
    updater = updated_card.updater
    recipients "#{user.email}"
    from       System.setting('*notify+*from') || User.find_by_login('wagbot').email
    subject    "[#{System.setting('*title')} notice] #{updater.card.name} #{action} \"#{card.name}\"" 
    content_type 'text/html'
    body :card => card,
         :updater => updater.card.name,
         :action => action,
         :subedits => subedits,
         :card_url => "#{System.base_url}/wagn/#{card.name.to_url_key}",
         :change_url => "#{System.base_url}/card/changes/#{card.name.to_url_key}",
         :unwatch_url => "#{System.base_url}/card/unwatch/#{watched.to_url_key}",
         :udpater_url => "#{System.base_url}/wagn/#{card.updater.card.name.to_url_key}",
         :watched => (watched == card.name ? "#{watched}" : "#{watched} cards")
  end
  

end

