
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
    link_to_card :signup, args[:link_text], args[:link_opts]
  end

  view :sign_in, perms: ->(_r) { !Auth.signed_in? },
                 denial: :blank do |args|
    link_to_card :signin, args[:link_text], args[:link_opts]
  end

  view :sign_out, perms: ->(_r) { Auth.signed_in? },
                  denial: :blank do |args|
    link_to_card :signin, args[:link_text], args[:link_opts]
  end

  view :invite, perms: ->(r) { r.show_invite_link? },
       denial: :blank do |args|
    link_to args[:link_text], args[:link_opts]
  end

  view :my_card, perms: ->(_r) { Auth.signed_in? },
                 denial: :blank do |_args|
    link_to_card Auth.current.cardname, nil, id: "my-card-link"
  end

  def default_sign_up_args args
    account_link_text :sign_up, args
    account_link_opts "signup-link", args, action: :new, type: :signup
  end

  def default_sign_in_args args
    account_link_text :invite, args
    account_link_opts "signin-link", args
  end

  def default_invite_args args
    account_link_text :invite, args
    account_link_opts "invite-a-friend-link", args, action: :new, type: :signup
  end

  def default_sign_out_args args
    account_link_text :sign_out, args
    account_link_opts "signout-link", args, action: :delete
  end

  def account_link_text purpose, args
    args[:link_text] =
      args.delete(:title) ||
      I18n.t(purpose, scope: "mod.standard.set.self.account_links")
  end

  def account_link_opts id, args, path=nil
    args[:link_opts] ||= {}
    args[:link_opts][:id] ||= id
    args[:link_opts][:path] ||= path if path
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
