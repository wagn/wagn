
format :html do
  def item_links _args=nil
    [:my_card, :invite, :sign_out, :sign_up, :sign_in].map do |link_view|
      optional_render link_view
    end
  end

  def self.link_options opts={}
    options = { denial: :blank, cache: :never }.merge opts
    options[:perms] = ->(r) { yield r } if block_given?
    options.clone
  end

  view :sign_up, link_options(&:show_signup_link?) do
    link_to_card :signup, account_link_text(:sign_up),
                 class: classy("signup-link"),
                 path: { action: :new, mark: :signup }
  end

  view :sign_in, link_options { !Auth.signed_in? } do
    link_to_card :signin, account_link_text(:sign_in),
                 class: classy("signin-link")
  end

  view :sign_out, link_options { Auth.signed_in? } do
    link_to_card :signin, account_link_text(:sign_out),
                 class: classy("signout-link"),
                 path: { action: :delete }
  end

  view :invite, link_options(&:show_invite_link?) do
    link_to_card :signup, account_link_text(:invite),
                 class: classy("invite-link"),
                 path: { action: :new, mark: :signup }
  end

  view :my_card, link_options { Auth.signed_in? } do
    link_to_card Auth.current.cardname, nil, class: "my-card-link"
  end

  def account_link_text purpose
    voo.title ||
      I18n.t(purpose, scope: "mod.standard.set.self.account_links")
  end

  view :raw do
    item_links.join " "
  end

  view(:navbar_right, cache: :never) { super() }


  view :core, cache: :never do
    status_class = Auth.signed_in? ? "logged-in" : "logged-out"
    wrap_with :span, id: "logging", class: status_class do
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
