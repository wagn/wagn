class Notifier < ActionMailer::Base
  def account_info(user, subject, message)
    from_user = User.current_user
    from_name = from_user.card ? from_user.card.name : ''

    recipients "#{user.email}"
    from       "#{from_name} <#{from_user.email}>"
    sent_on    Time.now
    subject    subject
    body  :username => (user.email    or raise Wagn::Oops.new("Oops didnn't have user email")),
          :password => (user.password or raise Wagn::Oops.new("Oops didn't have user password")),
          :url      => "#{System.base_url}/account/login",
          :message  => message.clone
  end                 
  
  def invitation_request_alert(invite_request)  
    subject "#{System.site_name}: Invitation Requested by #{invite_request.name}"
    from        "#{System.site_name}Bot <#{::User.find_by_login('admin').email}>" 
    recipients  System.invite_request_alert_email
    content_type 'text/html'
    body  :site => System.site_name,
          :card => invite_request,
          :email => invite_request.extension.email,
          :name => invite_request.name,
          :content => invite_request.content,
          :url =>  url_for(:host=>System.host, :controller=>'card', :action=>'show', :id=>Cardname.escape(invite_request.name))
  end

end

