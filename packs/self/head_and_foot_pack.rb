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
      bits << %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="#{ path(:edit, :card=>rcard) }"/>}
    end
    
    # RSS # move to packs!
    if rcard.typecode == 'Search'
      rss_href = rcard.name=='*search' ? "#{System.root_path}/search/#{ params[:_keyword] }.rss" : template.url_for_page( rcard.name, :format=>:rss )
      bits << %{<link rel="alternate" type="application/rss+xml" title="RSS" href=#{rss_href} />}
    end

    # CSS
    bits << stylesheet_link_tag('application-all')
    bits << stylesheet_link_tag('application-print', :media=>'print')
    if css_card = Card['*css']
      bits << stylesheet_link_tag("#{System.root_path}/*css.css?#{ css_card.current_revision_id }")
    end

    #Javscript
    bits << %(
    <script>
      var wagn = {}; window.wagn = wagn;
      wagn.root_path = '#{System.root_path}';
      window.tinyMCEPreInit = {base:"#{System.root_path}/assets/tinymce",query:"3.4.7",suffix:""};
      wagn.tinyMCEConfig = { #{System.setting('*tiny mce')} }
    </script>      
          )
    bits << javascript_include_tag('application')

    if ga_key=System.setting("*google analytics key")
      bits << %(
    
      <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '#{ga_key}']);
        _gaq.push(['_trackPageview']);

        (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
      </script>
      )
    end

    bits.join("\n")
  end
  alias_view(:raw, {:name=>'*head'}, :core)
  
  
  
  
  define_view(:raw, :name=>'*foot') do |args|
    '<!-- *foot is deprecated. please remove from layout -->'
  end
  alias_view(:raw, {:name=>'*foot'}, :core)

end
