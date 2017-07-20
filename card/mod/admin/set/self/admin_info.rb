def clean_html?
  false
end

format :html do
  view :core do
    warnings = []
    if Card.config.action_mailer.perform_deliveries == false
      warnings << email_warning
    end
    if Card.config.recaptcha_public_key ==
       Card::Auth::Permissions::RECAPTCHA_DEFAULTS[:recaptcha_public_key] &&
       card.rule(:captcha) == "1"
      warnings << recaptcha_warning
    end
    return "" if warnings.empty?
    alert :warning, true do
      render_warning_list warnings
    end
  end

  def render_warning_list warnings
    # 'ADMINISTRATOR WARNING'
    admin_warn = I18n.t(:admin_warn,
                        scope: "mod.admin.set.self.admin_info")
    "<h5>#{admin_warn}</h5>" + warnings.join("\n")
  end

  def email_warning
    # "Email delivery is turned off."
    # "Change settings in config/application.rb to send sign up notifications."
    I18n.t(:email_off,
           scope: "mod.admin.set.self.admin_info",
           path: "config/application.rb")
  end

  def recaptcha_warning
    warning =
      if Card::Env.localhost?
        # %(Your captcha is currently working with temporary settings.
        #   This is fine for a local installation, but you will need new
        #   recaptcha keys if you want to make this site public.)
        I18n.t(:captcha_temp, scope: "mod.admin.set.self.admin_info")
      else
        # %(You are configured to use [[*captcha]], but for that to work
        #   you need new recaptcha keys.)
        process_content(I18n.t(:captcha_keys,
                               scope: "mod.admin.set.self.admin_info"))
      end
    # 'Instructions'
    instructions = I18n.t(:instructions,
                          scope: "mod.admin.set.self.admin_info")
    <<-HTML
      <p>
        #{warning}
      </p>
      <h5>#{instructions}</h5>
      #{howto_add_new_recaptcha_keys}
      #{howto_turn_captcha_off}
    HTML
  end

  def instructions title, steps
    steps = list_tag steps, ordered: true
    "#{title}#{steps}"
  end

  def howto_add_new_recaptcha_keys
    instructions(
      I18n.t(:howto_add_keys, scope: "mod.admin.set.self.admin_info"),
      [
        I18n.t(:howto_register,
               scope: "mod.admin.set.self.admin_info",
               recaptcha_link: link_to_resource("http://google.com/recaptcha")),
        I18n.t(:howto_add,
               scope: "mod.admin.set.self.admin_info",
               recaptcha_settings: link_to_card(:recaptcha_settings))
      ]
    )
  end

  def howto_turn_captcha_off
    instructions(
      I18n.t(:howto_turn_off, scope: "mod.admin.set.self.admin_info"),
      [
        I18n.t(:howto_go,
               scope: "mod.admin.set.self.admin_info",
               captcha_card: link_to_card(:captcha)),
        I18n.t(:howto_update,
               scope: "mod.admin.set.self.admin_info")
      ]
    )
  end
end
