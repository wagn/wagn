
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

  view :sign_up, perms: ->(_r) { !Auth.signed_in? && Card.new(type_id: Card::SignupID).ok?(:create) },
                 denial: :blank do |_args|
    # 'Sign up'
    link_to(I18n.t(:sign_up, scope: "mod.05_standard.set.self.account_links"),
            card_path("account/signup"), id: "signup-link")
  end

  view :sign_in, perms: ->(_r) { !Auth.signed_in? },
                 denial: :blank do |_args|
    # 'Sign in'
    link_to(I18n.t(:sign_in, scope: "mod.05_standard.set.self.account_links"),
            card_path(":signin"), id: "signin-link")
  end

  view :invite, perms: ->(_r) {  Auth.signed_in? && Card.new(type_id: Card.default_accounted_type_id).ok?(:create) },
                denial: :blank do |_args|
    # 'Invite'
    link_to(I18n.t(:invite, scope: "mod.05_standard.set.self.account_links"),
            card_path("account/signup"), id: "invite-a-friend-link")
  end

  view :sign_out, perms: ->(_r) { Auth.signed_in? },
                  denial: :blank do |_args|
    # 'Sign out'
    link_to(I18n.t(:sign_out, scope: "mod.05_standard.set.self.account_links"),
            card_path("delete/:signin"), id: "signout-link")
  end

  view :my_card, perms: ->(_r) { Auth.signed_in? },
                 denial: :blank do |_args|
    card_link(Auth.current.cardname, id: "my-card-link")
  end

  view :raw do |args|
    item_links(args).join " "
  end

  view :core do |args|
    content_tag :span, id: "logging" do
      render_raw args
    end
  end
end
