
format :html do

  def account_links args
    [
      optional_render( :my_card, args),
      optional_render( :invite, args),
      optional_render( :sign_out, args),
      optional_render( :sign_up, args),
      optional_render( :sign_in, args)
    ]
  end
  
  #ENGLISH below
  view :sign_up, :perms=>lambda { |r| !Auth.signed_in? && Card.new(:type_id=>Card::SignupID).ok?(:create) }, 
                 :denial=>:blank do |args|
    link_to( 'Sign up', card_path('account/signup'), :id=>'signup-link' )
  end
  
  view :sign_in, :perms=>lambda { |r| !Auth.signed_in? },
                 :denial=>:blank do |args|
    link_to( 'Sign in', card_path(':signin'), :id=>'signin-link' )
  end
  
  view :invite, :perms=>lambda { |r|  Auth.signed_in? && Card.new(:type_id=>Card.default_accounted_type_id).ok?(:create) },
                :denial=>:blank do |args|
    link_to( 'Invite', card_path('account/signup'), :id=>'invite-a-friend-link' )
  end
  
  view :sign_out, :perms=>lambda { |r| Auth.signed_in? },
                  :denial=>:blank do |args|
    link_to( 'Sign out', card_path('delete/:signin'), :id=>'signout-link' )
  end 
  
  view :my_card, :perms=>lambda { |r| Auth.signed_in? },
                 :denial=>:blank do |args|
    card_link( Auth.current.cardname, :id=>'my-card-link' )
  end
  
  view :raw do |args|
    content_tag :span, :id=>'logging' do
      account_links(args).join ' '
    end
  end
  
  view :list do |args|
    content_tag :ul, :class=>args[:class] do
      account_links(args).map do |al|
        content_tag :li, al
      end.join "\n"
    end
  end
  
  view :navbar_right do |args|
    render_list args.merge(:class=>"nav navbar-nav navbar-right")
  end
  
  view :navbar_left do |args|
    render_list args.merge(:class=>"nav navbar-nav navbar-left")
  end
end
