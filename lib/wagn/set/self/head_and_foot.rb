module Wagn
  module Set::Self::HeadAndFoot
    include Sets

    format :html

    define_view :raw, :name=>'head' do |args|
      title = root.card && root.card.name
      title = nil if title.blank?
      title = params[:action] if title=='*placeholder'
      bits = ["<title>#{title ? "#{title} - " : ''}#{ Card.setting :title }</title>"]

      icon_card = nil
      [:favicon, :logo].find do |name|
        icon_card = Card[name] and icon_card.type_id == Card::ImageID and !icon_card.content.blank?
      end
      if icon_card
        bits << %{<link rel="shortcut icon" href="#{ subrenderer(icon_card)._render_source :size=>:icon }" />}
      end

      #Universal Edit Button
      if root.card
        if !root.card.new_record? && root.card.ok?(:update)
          bits << %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="#{ root.path :view=>:edit }"/>}
        end

        # RSS # move to packs!
        if root.card.type_id == Card::SearchTypeID
          opts = { :format => :rss }
          root.search_params[:vars].each { |key, val| opts["_#{key}"] = val }
          rss_href = page_path root.card.name, opts
          bits << %{<link rel="alternate" type="application/rss+xml" title="RSS" href=#{wagn_path rss_href} />}
        end
      end

      bits << %{<meta name="viewport" content="width=device-width, initial-scale=1.0"/>}
      # CSS
      #bits << stylesheet_link_tag('http://code.jquery.com/ui/1.9.1/themes/base/jquery-ui.css')
      bits << stylesheet_link_tag('application-all')
      bits << stylesheet_link_tag('application-print', :media=>'print')
      if css_card = Card[:css]
        local_css_path = wagn_path "*css.css?#{ css_card.current_revision_id }"
        bits << stylesheet_link_tag(local_css_path)
      end

      #Javscript
      bits << %(
      <script>
        var wagn = {};
        window.wagn = wagn;
        wagn.rootPath = '#{Wagn::Conf[:root_path]}';
        #{ Wagn::Conf[:recaptcha_on] ? %{wagn.recaptchaKey = "#{Wagn::Conf[:recaptcha_public_key]}";} : '' }
        #{ (c=Card[:double_click] and !Card.toggle(c.content)) ? 'wagn.noDoubleClick = true' : '' }
        #{ local_css_path ? %{ wagn.local_css_path = '#{local_css_path}'; } : '' }
        window.tinyMCEPreInit = {base:"#{wagn_path 'assets/tinymce'}",query:"3.5.8",suffix:""};
        wagn.tinyMCEConfig = { #{ Card.setting :tiny_mce } };
      </script>
      )
      # tinyMCE doesn't load on non-root wagns w/o preinit line above

      #bits << javascript_include_tag('http://code.jquery.com/jquery-1.8.2.js')
      #bits << javascript_include_tag('http://code.jquery.com/ui/1.9.1/jquery-ui.js')
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
    alias_view(:raw, {:name=>'head'}, :core)




    define_view :raw, :name=>'foot' do |args|
      '<!-- *foot is deprecated. please remove from layout -->'
    end
    alias_view(:raw, {:name=>'foot'}, :core)
  end
end
