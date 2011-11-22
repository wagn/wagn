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
      wagn.tinyMCEConfig = { #{System.setting('*tiny mce')} }
      #{ (ga_key=System.setting("*google analytics key")) ? "wagn.googleAnalyticsKey = '#{ga_key}'" : '' } 
    </script>      
          )
    bits << javascript_include_tag('application')

    bits.join("\n")
  end
  alias_view(:raw, {:name=>'*head'}, :core)
  
  
  
  
  define_view(:raw, :name=>'*foot') do |args|
    '<!-- *foot is deprecated. please remove from layout -->'
  end
  alias_view(:raw, {:name=>'*foot'}, :core)

end
