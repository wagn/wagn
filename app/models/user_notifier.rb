class UserNotifier < ActionMailer::Base
  def account_info(user, subject, message)
    @recipients  = "#{user.email}"
    @from        = "#{System.site_name} <#{System.admin_user.email}>"
    @sent_on     = Time.now
    @subject     = subject
    @body[:username] = user.email    or raise Wagn::Oops("Oops didnn't have user email")
    @body[:password] = user.password or raise Wagn::Oops("Oops didn't have user password")
    @body[:url]      = "#{System.base_url}/account/login"
    @body[:message] = message.clone
  end                 

end

