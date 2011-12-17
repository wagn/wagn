class Wagn::Renderer
  define_view(:raw, :name=>'*head') do |args|
    #rcard = card  # should probably be more explicit that this is really the *main* card.
    title = root.card && root.card.name
    title = params[:action] if [nil, '', '*placeholder'].member? title
    favicon_card = Card['*favicon'] || Card['*logo']
    
    bits = [
      "<title>#{title ? "#{title} - " : ''}#{ Card.setting('*title') }</title>",
      %{<link rel="shortcut icon" href="#{ subrenderer(favicon_card)._render_source :size=>:icon }" />}
    ]
    
    #Universal Edit Button
    if card
      if !card.new_record? && card.ok?(:update)
        bits << %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="#{ path(:edit, :card=>card) }"/>}
      end
      
      # RSS # move to packs!
      if card.typecode == 'Search'
        rss_href = card.name=='*search' ? "#{Wagn::Conf[:root_path]}/search/#{ params[:_keyword] }.rss" : template.url_for_page( card.name, :format=>:rss )
        bits << %{<link rel="alternate" type="application/rss+xml" title="RSS" href=#{rss_href} />}
     end
    end

    # CSS
    bits << stylesheet_link_tag('application-all')
    bits << stylesheet_link_tag('application-print', :media=>'print')
    if css_card = Card['*css']
      bits << stylesheet_link_tag("#{Wagn::Conf[:root_path]}/*css.css?#{ css_card.current_revision_id }")
    end

    #Javscript
    bits << %(
    <script>
      var wagn = {}; window.wagn = wagn;
      wagn.rootPath = '#{Wagn::Conf[:root_path]}';
      window.tinyMCEPreInit = {base:"#{Wagn::Conf[:root_path]}/assets/tinymce",query:"3.4.7",suffix:""}; #{
      Wagn::Conf[:recaptcha_on] ? %{wagn.recaptchaKey = "#{Wagn::Conf[:recaptcha_public_key]}"} : '' }
      wagn.tinyMCEConfig = { #{Card.setting('*tiny mce')} }
    </script>      
          )
    bits << javascript_include_tag('application')

    if ga_key=Card.setting("*google analytics key")
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
