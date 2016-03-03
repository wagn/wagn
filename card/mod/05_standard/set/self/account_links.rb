
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

  # ENGLISH below
  view :sign_up, perms: ->(_r) { !Auth.signed_in? && Card.new(type_id: Card::SignupID).ok?(:create) },
                 denial: :blank do |_args|
    link_to('Sign up', card_path('account/signup'), id: 'signup-link')
  end

  view :sign_in, perms: ->(_r) { !Auth.signed_in? },
                 denial: :blank do |_args|
    link_to('Sign in', card_path(':signin'), id: 'signin-link')
  end

  view :invite, perms: ->(_r) {  Auth.signed_in? && Card.new(type_id: Card.default_accounted_type_id).ok?(:create) },
                denial: :blank do |_args|
    link_to('Invite', card_path('account/signup'), id: 'invite-a-friend-link')
  end

  view :sign_out, perms: ->(_r) { Auth.signed_in? },
                  denial: :blank do |_args|
    link_to('Sign out', card_path('delete/:signin'), id: 'signout-link')
  end

  view :my_card, perms: ->(_r) { Auth.signed_in? },
                 denial: :blank do |_args|
    card_link(Auth.current.cardname, id: 'my-card-link')
  end

  view :raw do |args|
    item_links(args).join ' '
  end

  view :core do |args|
    content_tag :span, id: 'logging' do
      render_raw args
    end
  end
end
