
class Renderer

  # Declare built-in views
  view(:core, :name=>'*account link') do
    #ENGLISH
    %{
<span id="logging">#{
     if logged_in?
       @template.link_to "My Card: #{User.current_user.card.name}",
                                '/me',             :id=>'my-card-link'
       if System.ok?(:create_accounts)
         @template.link_to 'Invite a Friend',
                                '/account/invite', :id=>'invite-a-friend-link'
       end
       @template.link_to   'Sign out', '/account/signout', :id=>'signout-link'
     else
       if Card::InvitationRequest.create_ok?
         @template.link_to 'Sign up', '/account/signup',   :id=>'signup-link'
       end
       @template.link_to   'Sign in', '/account/signin',   :id=>'signin-link'
     end
    }</span>}
  end
  view_alias(:core, {:name=>'*account link'}, :raw)

  view(:core, :name=>'*alerts') do %{
<div id="alerts">
  <div id="notice"> flash[:notice] </div>
  <div id="error"> flash[:warning] flash[:error]</div>
</div>
} end
  view_alias(:core, {:name=>'*alerts'}, :raw)

  view(:core, :name=>'*foot') do
    javascript_include_tag "/tinymce/jscripts/tiny_mce/tiny_mce.js" +
    (google_analytics or '')
  end
  view_alias(:core, {:name=>'*foot'}, :raw)

  view(:core, :name=>'*head') do
    # ------- Title -------------
    %{
<link rel="shortcut icon" href="#{ System.favicon }" />#{
      if card and !card.new_record? and card.ok? :edit
        %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="/card/edit/#{ card.key }"/>}
      end}#{

      if card and card.name == "*search"
        %{<link rel="alternate" type="application/rss+xml" title="RSS" href="/search/<%= params[:_keyword] %>.rss" />}
      elsif card and Card::Search === card
        %{<link rel="alternate" type="application/rss+xml" title="RSS" href="#{ @template.url_for_page( card.name, :format=>:rss )} " />}
      end}

  <title> #{
    (@card.name=='*recent changes' ? 'Recently Changed Cards' : @card.name) ||
      params[:title] } - #{ System.site_title } </title>
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
  view_alias(:core, {:name=>'*head'}, :raw)

  view(:core, :name=>'*navbox') do
    Rails.logger.info("Builtin *navbox")
    #ENGLISH
    %{
<form id="navbox_form" action="/search" onsubmit="return navboxOnSubmit(this)">
  <span id="navbox_background">
    <a id="navbox_image" title="Search" onClick="navboxOnSubmit($('navbox_form'))">&nbsp;</a>
    <input type="text" name="navbox" value="#{ params[:_keyword] || '' }" id="navbox_field" autocomplete="off" />
     #{ navbox_complete_field('navbox_field') }
  </span>
</form>
    }
  end
  view_alias(:core, {:name=>'*navbox'}, :raw)

  view(:core, :name=>'*now') do Time.now.strftime('%A, %B %d, %Y %I:%M %p %Z') end
  view_alias(:core, {:name=>'*now'}, :raw)
  view(:core, :name=>'*version') do Wagn::Version.full end
  view_alias(:core, {:name=>'*version'}, :raw)

  view(:content, :type=>'basic') do _render_core end
  view(:line, :type=>'basic') do truncatewords_with_closing_tags( _render_core ) end

  view(:editor, :type=>'basic') do
    %{#{
      javascript_include_tag "/tinymce/jscripts/tiny_mce/tiny_mce.js" } #{
      eid, raw_id = context, context+'-raw-content'
      form.hidden_field :content, :id=>"#{eid}-hidden-content"}#{
      text_area_tag :content_to_replace, card.content, :rows=>3, :id=>"#{eid}-tinymce"}#{
      editor_hooks :setup=> %{setTimeout((function(){
  tinyMCE.init({mode: "exact",elements: "#{eid}-tinymce",#{System.setting('*tiny mce') || ''}})
  tinyMCE.execInstanceCommand( '#{eid}-tinymce', 'mceFocus' );
}),50); 
  }, :save=> %{t = tinyMCE.getInstanceById( '#{eid}-tinymce' ); $('#{eid}-hidden-content').value = t.getContent(); return true;} 
    }}
  end
end
