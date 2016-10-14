
format :html do
  def item_links _args=nil
    [:my_card, :invite, :sign_out, :sign_up, :sign_in].map do |link_view|
      optional_render link_view
    end
  end

  view :sign_up, perms: ->(r) { r.show_signup_link? }, denial: :blank do
    link_to_card :signup, account_link_text(:sign_up),
                 id: "signup-link", path: { action: :new, mark: :signup }
  end

  view :sign_in, perms: ->(_r) { !Auth.signed_in? }, denial: :blank do
    link_to_card :signin, account_link_text(:sign_in), id: "signin-link"
  end

  view :sign_out, perms: ->(_r) { Auth.signed_in? }, denial: :blank do
    link_to_card :signin, account_link_text(:sign_out),
                 id: "signout-link", path: { action: :delete }
  end

  view :invite, perms: ->(r) { r.show_invite_link? }, denial: :blank do
    link_to account_link_text(:invite),
            id: "invite-a-friend-link", path: { action: :new, mark: :signup }
  end

  view :my_card, perms: ->(_r) { Auth.signed_in? }, denial: :blank do
    link_to_card Auth.current.cardname, nil, id: "my-card-link"
  end

  def account_link_text purpose
    voo.title ||
      I18n.t(purpose, scope: "mod.standard.set.self.account_links")
  end

  view :raw do
    item_links.join " "
  end

  view :core do
    status_class = Auth.signed_in? ? "logged-in" : "logged-out"
    content_tag :span, id: "logging", class: status_class do
      render_raw
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
