class Notifier < ActionMailer::Base
  def account_info(user, subject, message)
    from_user = User.current_user || User[:admin]
    from_name = from_user.card ? from_user.card.name : ''
    url_key = user.card.name.to_url_key

    recipients "#{user.email}"
    from       (System.setting('*invite+*from') || "#{from_name} <#{from_user.email}>") #FIXME - might want different from settings for different emails?
    sent_on    Time.now
    subject    subject
    body  :email    => (user.email    or raise Wagn::Oops.new("Oops didn't have user email")),
          :password => (user.password or raise Wagn::Oops.new("Oops didn't have user password")),
          
          :card_url => "#{System.base_url}/wagn/#{url_key}",
          :pw_url   => "#{System.base_url}/card/options/#{url_key}",
          
          :login_url=> "#{System.base_url}/account/signin",
          :message  => message.clone
  end                 
  
  def signup_alert(invite_request)  
    subject "#{invite_request.name} signed up for #{System.site_title}"
    from        System.setting('*signup+*from') || invite_request.extension.email
    recipients  System.setting('*signup+*to')
    content_type 'text/html'
    body  :site => System.site_title,
          :card => invite_request,
          :email => invite_request.extension.email,
          :name => invite_request.name,
          :content => invite_request.content,
          :url =>  url_for(:host=>System.host, :controller=>'card', :action=>'show', :id=>invite_request.name.to_url_key)
  end

end

