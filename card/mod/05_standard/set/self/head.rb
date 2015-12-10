format :html do
  view :raw do
    %(
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
      #{ head_title       }
      #{ head_buttons     }
      #{ head_stylesheets }
      #{ head_javascript  }
    )
  end

  view :core do |args|
    case
    when focal?    then CGI.escapeHTML _render_raw(args)
    when @mainline then "(*head)"
    else _render_raw(args)
    end
  end

  def head_title
    title = root.card && root.card.name
    title = nil if title.blank?
    title = params[:action] if title=='*placeholder'
    %(<title>#{title ? "#{title} - " : ''}#{ Card.global_setting :title }</title>)
  end

  def head_buttons
    bits = [favicon]
    if root.card
      bits << universal_edit_button
      # RSS # move to mods!
      if root.card.type_id == SearchTypeID
        bits << rss_link
      end
    end
    bits.compact.join "\n      "
  end

  def favicon
    [:favicon, :logo].each do |name|
      if (c = Card[name]) && c.type_id == ImageID && !c.db_content.blank?
        href = subformat(c)._render_source size: :small
        return %{<link rel="shortcut icon" href="#{ href }" />}
      end
    end
  end

  def universal_edit_button
    return if root.card.new_record? || !root.card.ok?(:update)
    href = root.path view: :edit
    %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="#{ href }"/>}
  end

  def rss_link
    opts = { format: :rss }
    root.search_params[:vars].each { |key, val| opts["_#{key}"] = val }
    href = page_path root.card.cardname, opts
    %{<link rel="alternate" type="application/rss+xml" title="RSS" href="#{href}" />}
  end

  def head_stylesheets
    manual_style = params[:style]
    style_card = Card[manual_style] if manual_style
    style_card ||= root.card.rule_card :style
    @css_path =
      if params[:debug] == 'style'
      page_path(style_card.cardname, item: :import, format: :css)
      elsif style_card
        card_path style_card.machine_output_url
      end
    return unless @css_path
    %{<link href="#{@css_path}" media="all" rel="stylesheet" type="text/css" />}
  end

  def head_javascript
    varvals = [
      "window.wagn={rootPath:'#{ Card.config.relative_url_root }'}",
      # tinyMCE doesn't load on non-root wagns w/o preinit line
      "window.tinyMCEPreInit={base:\"#{card_path 'assets/tinymce'}\",query:'3.5.9',suffix:''}"
    ]
    card.have_recaptcha_keys? &&
      varvals << "wagn.recaptchaKey='#{Card.config.recaptcha_public_key}'"
    (c = Card[:double_click]) && !Card.toggle(c.content) &&
      varvals << 'wagn.noDoubleClick=true'
    @css_path &&
      varvals << "wagn.cssPath='#{@css_path}'"

    manual_script = params[:script]
    script_card   = Card[manual_script] if manual_script
    script_card ||= root.card.rule_card :script

    @js_tag =
      if params[:debug] == 'script'
        script_card.format(:js).render_core item: :include_tag
      elsif script_card
        javascript_include_tag script_card.machine_output_url
      end
    ie9_card = Card[:script_html5shiv_printshiv]
    <<-HTML
      #{ javascript_tag do varvals * ';' end  }
      #{ @js_tag if @js_tag }
      <!--[if lt IE 9]>#{ javascript_include_tag ie9_card.machine_output_url if ie9_card }<![endif]-->
      #{ javascript_tag { "wagn.setTinyMCEConfig('#{ escape_javascript Card.global_setting(:tiny_mce).to_s }')" } }
      #{ google_analytics_head_javascript }
      <script type="text/javascript">
        $('document').ready(function() {
          $('.card-slot').trigger('slotReady');
        })
      </script>
    HTML
  end


  def google_analytics_head_javascript
    return unless (ga_key = Card.global_setting(:google_analytics_key))
    <<-JAVASCRIPT
      <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '#{ga_key}']);
        _gaq.push(['_trackPageview']);
        (function() {
          var ga = document.createElement('script');
          ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0];
          s.parentNode.insertBefore(ga, s);
          s.parentNode.insertBefore(ga, s);
        })();
      </script>
    JAVASCRIPT
  end
end
