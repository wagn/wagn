view :core do |args|
  warning = ''
  if Card.config.action_mailer.perform_deliveries == false
    warning += "<li class='list-group-item list-group-item-warning'>Email delivery is turned off. Change settings in config/application.rb to send sign up notifications.</li>"
  end
  if Card.config.recaptcha_public_key == Card::Auth::DEFAULT_RECAPTCHA_SETTINGS[:recaptcha_public_key]
    warning +=  "<li class='list-group-item list-group-item-warning'>" + process_content(
                   "You are using Wagn's default recaptcha key.
                    That's fine for a local installation.
                    If you want to use recaptcha for a publicly available Wagn installation
                    you have to register your domain at http://google.com/recaptcha and
                    add your keys to [[*recaptcha settings]]. To turn off captchas go to the
                    captcha rule card [[*all+*captcha]]") + "</li>"
  end
  if warning.present?
    content_tag :div, :class=>"alert alert-warning alert-dismissible", :role=>"alert" do
      %{
        <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h6>WARNING</h6>
        <ul class="list-group">#{warning}</ul>
      }.html_safe
    end
  else
    ''
  end
end