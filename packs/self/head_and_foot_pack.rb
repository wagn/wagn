class Wagn::Renderer
  define_view(:raw, :name=>'*head') do |args|
    rcard = root.card  # should probably be more explicit that this is really the *main* card.
    title = rcard.name
    title = params[:action] if title.nil? || title == '*placeholder'

    bits = [
      "<title>#{title ? "#{title} - " : ''}#{ System.site_title }</title>",
      %{<link rel="shortcut icon" href="#{ System.favicon }" />}
    ]
    
    #Universal Edit Button
    if !rcard.new_record? && rcard.ok?(:update)
      bits << %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="/card/edit/#{ rcard.cardname.to_url_key }"/>}
    end
    
    # RSS
    if rcard.typecode == 'Search'
      rss_href = rcard.name=='*search' ? "/search/#{ params[:_keyword] }.rss" : template.url_for_page( rcard.name, :format=>:rss )
      bits << %{<link rel="alternate" type="application/rss+xml" title="RSS" href=#{rss_href} />}
    end
    
    # CSS
    bits += [stylesheet_link_merged(:base), stylesheet_link_tag( 'print', :media=>'print') ]
    if star_css_card = Card['*css']
      bits << %{<link href="/*css.css?#{ star_css_card.current_revision_id }" media="screen" type="text/css" rel="stylesheet" />}
    end

    #Javscript
    bits << javascript_include_merged(:base)
    
    bits.join("\n")
  end
  alias_view(:raw, {:name=>'*head'}, :naked)
  
  
  
  
  define_view(:raw, :name=>'*foot') do |args|
    User.as(:wagbot) do
      javascript_include_tag("/tinymce/jscripts/tiny_mce/tiny_mce.js") +
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
  alias_view(:raw, {:name=>'*foot'}, :naked)

end
