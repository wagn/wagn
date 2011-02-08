class Renderer

  # make sure builtin cards exist
  def self.create_builtins
    User.as :wagbot do
      %w{ *account *alerts *foot *head *navbox *now *version }.map do |name|
Rails.logger.info "create builtin cards #{name}"
        c=Card.fetch_or_new(name)
        c.save
      end
    end
  end

  # Declare built-in views
  view(:core, :name=>'*account') do
    #ENGLISH
    %{<span id="logging">#{
     if logged_in?
       link_to "My Card: #{current_user.card.name}", '/me', :id=>'my-card-link'
       if System.ok?(:create_accounts)
         link_to 'Invite a Friend', {:controller=>'account', :action=>'invite'}, :id=>'invite-a-friend-link'
       end
       link_to 'Sign out', {:controller=>'account', :action=>'signout'}, :id=>'signout-link'
     else
       if Card::InvitationRequest.create_ok?
         link_to 'Sign up', {:controller=>'account', :action=>'signup'}, :id=>'signup-link'
       end
       link_to 'Sign in', {:controller=>'account', :action=>'signin'}, :id=>'signin-link'
     end
    }</span>}
  end

  view(:core, :name=>'*alerts') do
    %{<div id="alerts">
  <div id="notice">#{ flash[:notice] }</div>
  <div id="error">#{ flash[:warning] }#{ flash[:error] }</div>  
</div>}
  end

  view(:core, :name=>'*foot') do
    javascript_include_tag "/tinymce/jscripts/tiny_mce/tiny_mce.js" +
    (google_analytics or '')
  end

  view(:core, :name=>'*head') do
    # ------- Title -------------
    %{<link rel="shortcut icon" href="#{ System.favicon }" />#{
      if card and !card.new_record? and card.ok? :edit
        %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="/card/edit/#{ card.key }"/>}
      end}#{

      if card and card.name == "*search"
        %{<link rel="alternate" type="application/rss+xml" title="RSS" href="/search/<%= params[:_keyword] %>.rss" />}
      elsif card and Card::Search === card
        %{<link rel="alternate" type="application/rss+xml" title="RSS" href="#{ url_for_page( card.name, :format=>:rss )} " />}
      end}

  <title>
    #{ @title || "#{controller ? controller.controller_name : self} - #{controller && controller.action_name}" }
    - #{ System.site_title }
  </title>
    #{ stylesheet_link_merged(:base) }#{
       if star_css_card = Card.fetch('*css', :skip_virtual => true)
    %{<link href="/*css.css?<%= star_css_card.current_revision_id %>" media="screen" type="text/css" rel="stylesheet" />}
       end}#{#asset_manager can do alternate media but has to be a separate call
        %{ stylesheet_link_tag 'print', :media=>'print' } +
        # tried javascript at bottom, much breakage
        javascript_include_merged(:base) +
        key = System.setting("*google_ajax_api_key") ?
         %{<script type="text/javascript" src="http://www.google.com/jsapi?key=<%= key %>"></script>} : ''
       }
    }
  end

  view(:core, :name=>'*navbox') do
    #ENGLISH
    %{<form id="navbox_form" action="/search" onsubmit="return navboxOnSubmit(this)">
  <span id="navbox_background">
    <a id="navbox_image" title="Search" onClick="navboxOnSubmit($('navbox_form'))">&nbsp;</a>
    <input type="text" name="navbox" value="#{ params[:_keyword] || '' }" id="navbox_field" autocomplete="off" />
     #{ navbox_complete_field('navbox_field') }
  </span>
</form>}
  end

  view(:core, :name=>'*now') do
    Time.now.strftime('%A, %B %d, %Y %I:%M %p %Z')
  end

  view(:core, :name=>'*version') do Wagn::Version.full end

end
