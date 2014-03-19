# -*- encoding : utf-8 -*-

format :html do

  view :raw do |args|
    %(
      <meta charset="UTF-8">  
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>    
      #{ head_title     }
      #{ head_buttons     }
      #{ head_stylesheets }
      #{ head_javascript }      
    )
  end

  view :core, :raw
  
  view :content do |args|
    wrap args.merge(:slot_class=>'card-content') do
      CGI.escapeHTML render_raw
    end
  end
  
  def head_title
    title = root.card && root.card.name
    title = nil if title.blank?
    title = params[:action] if title=='*placeholder'
    %(<title>#{title ? "#{title} - " : ''}#{ Card.setting :title }</title>) 
  end
  
  def head_buttons
    bits = []
    [:favicon, :logo].each do |name|
      if c = Card[name] and c.type_id == ImageID and !c.content.blank?
        bits << %{<link rel="shortcut icon" href="#{ subformat(c)._render_source :size=>:icon }" />}
        break
      end
    end

    #Universal Edit Button
    if root.card
      if !root.card.new_record? && root.card.ok?(:update)
        bits << %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="#{ root.path :view=>:edit }"/>}
      end

      # RSS # move to mods!
      if root.card.type_id == SearchTypeID
        opts = { :format => :rss }
        root.search_params[:vars].each { |key, val| opts["_#{key}"] = val }
        rss_href = page_path root.card.name, opts
        bits << %{<link rel="alternate" type="application/rss+xml" title="RSS" href=#{wagn_path rss_href} />}
      end
    end
    bits.join "\n      "
  end
  
  def head_stylesheets
    manual_style = params[:style]
    debug        = params[:debug] == 'style'
    style_rule   = card.rule_card :style
    
    if manual_style or debug   
      path_args = { :format=>:css }
      path_args[:item] = :import if debug
      style_cardname = manual_style || (style_rule && style_rule.name)
      @css_path = page_path style_cardname, path_args
    elsif style_rule
      @css_path = wagn_path style_rule.style_path
    end 

    if @css_path
      %{<link href="#{@css_path}" media="all" rel="stylesheet" type="text/css" />}
    end
  end
  
  def head_javascript
    varvals = [
      "window.wagn={rootPath:'#{ Wagn.config.relative_url_root }'}",
      "window.tinyMCEPreInit={base:\"#{wagn_path 'assets/tinymce'}\",query:'3.5.9',suffix:''}" # tinyMCE doesn't load on non-root wagns w/o preinit line
    ]
    Env.recaptcha_on?                               and varvals << "wagn.recaptchaKey='#{Wagn.config.recaptcha_public_key}'"
    c=Card[:double_click] and !Card.toggle c.content and varvals << 'wagn.noDoubleClick=true'
    @css_path                                        and varvals << "wagn.cssPath='#{@css_path}'"
    
    %(#{ javascript_tag do varvals * ';' end  }      
      #{ javascript_include_tag 'application' }
      <!--[if lt IE 9]>#{ javascript_include_tag 'html5shiv-printshiv' }<![endif]-->
      #{ javascript_tag { "wagn.setTinyMCEConfig('#{ escape_javascript Card.setting(:tiny_mce).to_s }')" } }
      #{ google_analytics_head_javascript })
  end
    
  
  def google_analytics_head_javascript
    if ga_key = Card.setting("*google analytics key") #fixme.  escape this?
      %{
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
      }
    end
  end
end


