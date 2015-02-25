
format :html do

  def account_links
    #ENGLISH
    links = []
    if Auth.signed_in?
      links << card_link( Auth.current.cardname, :id=>'my-card-link' )
      if Card.new(:type_id=>Card.default_accounted_type_id).ok? :create
        # Shouldn't these use the new paths?
        links << link_to( 'Invite', card_path('account/signup'), :id=>'invite-a-friend-link' )
      end
      links << link_to( 'Sign out', card_path('delete/:signin'), :id=>'signout-link' )
    else
      if Card.new(:type_id=>Card::SignupID).ok? :create
        links << link_to( 'Sign up', card_path('account/signup'), :id=>'signup-link' )
      end
      links << link_to( 'Sign in', card_path(':signin'), :id=>'signin-link' )
    end
    links
  end
  
  
  view :sign_up do |args|
    if !Auth.signed_in? && Card.new(:type_id=>Card::SignupID).ok?(:create)
      link_to( 'Sign up', card_path('account/signup'), :id=>'signup-link' )
    else
      ''
    end
  end
  
  view :sign_in do |args|
    if !Auth.signed_in?
      link_to( 'Sign in', card_path(':signin'), :id=>'signin-link' )
    else
      ''
    end
  end
  
  view :invite do |args|
    if Auth.signed_in? && Card.new(:type_id=>Card.default_accounted_type_id).ok?(:create)
      link_to( 'Invite', card_path('account/signup'), :id=>'invite-a-friend-link' )
    else
      ''
    end
  end
  
  view :sign_out do |args|
    if Auth.signed_in?
      link_to( 'Sign out', card_path('delete/:signin'), :id=>'signout-link' )
    else
      ''
    end
  end 
  
  view :my_card do |args|
    if Auth.signed_in?
      card_link( Auth.current.cardname, :id=>'my-card-link' )
    else
      ''
    end
  end
  
  view :raw do |args|
    content_tag :span, :id=>'logging' do
      [
        _optional_render( :my_card, args),
        _optional_render( :invite, args),
        _optional_render( :sign_out, args),
        _optional_render( :sign_up, args),
        _optional_render( :sign_in, args)
      ].join ' '
    end
    #%{<span id="logging">#{ account_links.join ' ' }</span>}
  end
  
  view :list do |args|
    content_tag :ul, :class=>args[:class] do
      account_links.map do |al|
        content_tag :li, al
      end.join "\n"
    end
  end
  
  view :list_navbar_right do |args|
    render_list args.merge(:class=>"nav navbar-nav navbar-right")
  end
  
  view :list_navbar_left do |args|
    render_list args.merge(:class=>"nav navbar-nav navbar-left")
  end
end
