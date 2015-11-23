view :core do
  warnings = []
  if Card.config.action_mailer.perform_deliveries == false
    warnings << email_warning
  end
  if Card.config.recaptcha_public_key ==
     Card::Auth::DEFAULT_RECAPTCHA_SETTINGS[:recaptcha_public_key]
    warnings << recaptcha_warning
  end
  return '' if warnings.empty?
  alert :warning, dismissible: true do
    render_warning_list warnings
  end
end

def render_warning_list warnings
  '<h6>WARNING</h6>'.html_safe + list_tag(
    warnings,
    class: 'list-group',
    items: {
      class: 'list-group-item list-group-item-warning'
    }
  )
end

def email_warning
  %{
    Email delivery is turned off.
    Change settings in config/application.rb to send sign up notifications.
  }
end

def recaptcha_warning
  process_content %{
    You are using Wagn's default recaptcha key.
    That's fine for a local installation.
    If you want to use recaptcha for a publicly available Wagn installation
    you have to register your domain at http://google.com/recaptcha and
    add your keys to [[*recaptcha settings]]. To turn off captchas go to the
    captcha rule card [[*all+*captcha]
  }
end
