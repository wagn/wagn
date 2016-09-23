
format :html do
  def item_links args
    [
      optional_render(:my_card, args),
      optional_render(:invite, args),
      optional_render(:sign_out, args),
      optional_render(:sign_up, args),
      optional_render(:sign_in, args)
    ]
  end

  view :sign_up, perms: ->(r) { r.show_signup_link? },
                 denial: :blank do |args|
    link_text = args[:title] ||
                I18n.t(:sign_up, scope: "mod.standard.set.self.account_links")
    path_opts = { action: :new, type: :signup }
    link_to_card :signup, link_text, path: path_opts, id: "signup-link"
  end

  view :sign_in, perms: ->(_r) { !Auth.signed_in? },
                 denial: :blank do |_args|
    link_text = I18n.t :sign_in, scope: "mod.standard.set.self.account_links"
    link_to_card :signin, link_text, id: "signin-link"
  end

  view :invite, perms: ->(r) { r.show_invite_link? },
                denial: :blank do |_args|
    link_text = I18n.t :invite, scope: "mod.standard.set.self.account_links"
    path_opts = { action: :new, type: :signup }
    link_to link_text, path: path_opts, id: "invite-a-friend-link"
  end

  view :sign_out, perms: ->(_r) { Auth.signed_in? },
                  denial: :blank do |_args|
    link_text = I18n.t :sign_out, scope: "mod.standard.set.self.account_links"
    path_opts = { action: :delete }
    link_to_card :signin, link_text, path: path_opts, id: "signout-link"
  end

  view :my_card, perms: ->(_r) { Auth.signed_in? },
                 denial: :blank do |_args|
    link_to_card Auth.current.cardname, nil, id: "my-card-link"
  end

  view :raw do |args|
    item_links(args).join " "
  end

  view :core do |args|
    status_class = Auth.signed_in? ? "logged-in" : "logged-out"
    content_tag :span, id: "logging", class: status_class do
      render_raw args
    end
  end

  def show_signup_link?
    !Auth.signed_in? && Card.new(type_id: Card::SignupID).ok?(:create)
  end

  def show_invite_link?
    Auth.signed_in? &&
      Card.new(type_id: Card.default_accounted_type_id).ok?(:create)
  end
end
