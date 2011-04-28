
class Renderer

  # Declare built-in views
  define_view(:raw, :name=>'*account link') do
    #ENGLISH
    text = '<span id="logging">'
     if logged_in?
       text += @template.link_to( "My Card: #{User.current_user.card.name}", '/me', :id=>'my-card-link')
       if System.ok?(:create_accounts)
         text += @template.link_to('Invite a Friend', '/account/invite', :id=>'invite-a-friend-link')
       end
       text += @template.link_to('Sign out', '/account/signout', :id=>'signout-link')
     else
       if Card::InvitationRequest.create_ok?
         text+= @template.link_to( 'Sign up', '/account/signup',   :id=>'signup-link' )
       end
       text += @template.link_to( 'Sign in', '/account/signin',   :id=>'signin-link' )
     end
    text + '</span>'
  end
  
  view_alias(:raw, {:name=>'*account link'}, :naked)



  define_view(:raw, :name=>'*alerts') do %{
<div id="alerts">
  <div id="notice">#{flash[:notice]} </div>
  <div id="error">#{flash[:warning]}#{flash[:error]}</div>
</div>
} end
  view_alias(:raw, {:name=>'*alerts'}, :naked)



  define_view(:raw, :name=>'*foot') do
    javascript_include_tag "/tinymce/jscripts/tiny_mce/tiny_mce.js" +
    User.as(:wagbot)  do
      if ga_key = System.setting("*google analytics key")
        %{
          <script type="text/javascript">
            // make sure this is only run once:  it may be called twice in the case that you are viewing a *layout page
            if (typeof(pageTracker)=='undefined') {
              var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
              document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
            }
          </script>
          <script type="text/javascript">
            pageTracker = _gat._getTracker('#{ga_key}');
            pageTracker._trackPageview();
          </script>
        }
      else; ''; end
    end
  end
  view_alias(:raw, {:name=>'*foot'}, :naked)



  define_view(:raw, :name=>'*head') do
    rcard = root.card
    title = rcard.name
    title = params[:action] if title.nil? || title == '*placeholder'

    bits = [
      "<title>#{title ? "#{title} - " : ''}#{ System.site_title }</title>",
      %{<link rel="shortcut icon" href="#{ System.favicon }" />}
    ]
    
    #Universal Edit Button
    if !rcard.new_record? && rcard.ok?(:edit)
      bits << %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="/card/edit/#{ rcard.name.to_url_key }"/>}
    end
    
    # RSS
    if Card::Search === rcard
      rss_href = rcard.name=='*search' ? "/search/#{ params[:_keyword] }.rss" : @template.url_for_page( rcard.name, :format=>:rss )
      bits << %{<link rel="alternate" type="application/rss+xml" title="RSS" href=#{rss_href} />}
    end
    
    # CSS
    bits += [stylesheet_link_merged(:base), stylesheet_link_tag( 'print', :media=>'print') ]
    if star_css_card = Card.fetch('*css', :skip_virtual => true)
      bits << %{<link href="/*css.css?#{ star_css_card.current_revision_id }" media="screen" type="text/css" rel="stylesheet" />}
    end

    #Javscript
    bits << javascript_include_merged(:base)
    
    bits.join("\n")
  end
  view_alias(:raw, {:name=>'*head'}, :naked)



  define_view(:raw, :name=>'*navbox') do
#Rails.logger.debug("Builtin *navbox")
    #ENGLISH
    %{
<form id="navbox_form" action="/search" onsubmit="return navboxOnSubmit(this)">
  <span id="navbox_background">
    <a id="navbox_image" title="Search" onClick="navboxOnSubmit($('navbox_form'))">&nbsp;</a>
    <input type="text" name="navbox" value="#{ params[:_keyword] || '' }" id="navbox_field" autocomplete="off" />
    #{ #navbox_complete_field('navbox_field')
      content_tag("div", "", :id => "navbox_field_auto_complete", :class => "auto_complete") +
      auto_complete_field('navbox_field', {
        :url =>"/card/auto_complete_for_navbox/",
        :after_update_element => "navboxAfterUpdate" }.update({}))
    }
  </span>
</form>
    }
  end
  view_alias(:raw, {:name=>'*navbox'}, :naked)

  define_view(:raw, :name=>'*now') do Time.now.strftime('%A, %B %d, %Y %I:%M %p %Z') end
  view_alias(:raw, {:name=>'*now'}, :naked)
  define_view(:raw, :name=>'*version') do Wagn::Version.full end
  view_alias(:raw, {:name=>'*version'}, :naked)


  private
  def navbox_complete_field(fieldname, card_id='')
    content_tag("div", "", :id => "#{fieldname}_auto_complete", :class => "auto_complete") +
    auto_complete_field(fieldname, { :url =>"/card/auto_complete_for_navbox/#{card_id.to_s}",
      :after_update_element => "navboxAfterUpdate"
     }.update({}))
  end

end
