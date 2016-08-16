format :html do
  # add tuples containing a
  #  - the codename of a card with javascript config (usually in json format)
  #  - the name of a javascript method that handles the config
  basket :mod_js_config

  def script_rule
    manual_script = params[:script]
    script_card   = Card[manual_script] if manual_script
    script_card ||= root.card.rule_card :script

    @js_tag =
      if params[:debug] == "script"
        script_card.format(:js).render_core item: :include_tag
      elsif script_card
        javascript_include_tag script_card.machine_output_url
      end
  end

  def ie9
    ie9_card = Card[:script_html5shiv_printshiv]
    "<!--[if lt IE 9]>"\
    "#{javascript_include_tag ie9_card.machine_output_url if ie9_card}"\
    "<![endif]-->"
  end

  def wagn_variables
    varvals = ["window.wagn={rootPath:'#{Card.config.relative_url_root}'}",]
    card.have_recaptcha_keys? &&
      varvals << "wagn.recaptchaKey='#{Card.config.recaptcha_public_key}'"
    (c = Card[:double_click]) && !Card.toggle(c.content) &&
      varvals << "wagn.noDoubleClick=true"
    @css_path &&
      varvals << "wagn.cssPath='#{@css_path}'"
    javascript_tag { varvals * ";" }
  end

  def trigger_slot_ready
    <<-HTML
      <script type="text/javascript">
        $('document').ready(function() {
          $('.card-slot').trigger('slotReady');
        })
      </script>
    HTML
  end

  def google_analytics
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

  def mod_configs
    mod_js_config.map do |codename, js_wagn_function|
      config_json = escape_javascript Card.global_setting(codename)
      javascript_tag { "wagn.#{js_wagn_function}('#{config_json}')" }
    end
  end
end